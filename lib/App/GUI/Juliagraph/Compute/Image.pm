
# compute fractal

package App::GUI::Juliagraph::Compute::Image;
use v5.12;
use warnings;
use Benchmark;
use Graphics::Toolkit::Color qw/color/;
use Wx;

use constant SKETCH_FACTOR => 4;

sub colors {
    my( $set, $max_iter ) = @_;
    my (@gradient, %gradient_mapping, $gradient_total_length, @color, $background_color);

    if ($set->{'mapping'}{'custom_partition'}){
        $gradient_total_length = $set->{'mapping'}{'scale_parts'};
        my $last_part_nr = $gradient_total_length - 1;
        my @all_but_not_last_part = 0 .. $set->{'mapping'}{'scale_parts'} - 2;
        my $linear_gradient_part_length = $max_iter / $gradient_total_length;
        if ($set->{'mapping'}{'scale_distro'} eq 'linear'){
            for my $part_nr (@all_but_not_last_part) {
                my $index_base = keys %gradient_mapping;
                $gradient_mapping{$index_base + $_} = $part_nr for 0 .. $linear_gradient_part_length - 1;
            }
        } elsif ($set->{'mapping'}{'scale_distro'} eq 'square'){
            my $gradient_part_length = $max_iter / ($set->{'mapping'}{'scale_parts'} ** 2);
            my $gradient_part_length_delta = $gradient_part_length * 2;
            for my $part_nr (@all_but_not_last_part) {
                my $index_base = keys %gradient_mapping;
                $gradient_mapping{$index_base + $_} = $part_nr for 0 .. $gradient_part_length - 1;
                $gradient_part_length += $gradient_part_length_delta;
            }
        } elsif ($set->{'mapping'}{'scale_distro'} eq 'cube'){
            my $gradient_part_length = $max_iter / ($set->{'mapping'}{'scale_parts'} ** 3);
            my $gradient_part_length_delta = $gradient_part_length * 6;
            my $gradient_part_length_dd = $gradient_part_length_delta;
            for my $part_nr (@all_but_not_last_part) {
                my $index_base = keys %gradient_mapping;
                $gradient_mapping{$index_base + $_} = $part_nr for 0 .. $gradient_part_length - 1;
                $gradient_part_length += $gradient_part_length_delta;
                $gradient_part_length_delta += $gradient_part_length_dd;
            }
        } elsif ($set->{'mapping'}{'scale_distro'} eq 'sqrt'){
            my $scale_max = sqrt ($set->{'mapping'}{'scale_parts'}+1);
            for my $part_nr (@all_but_not_last_part) {
                my $gradient_part_length = (sqrt($part_nr+2)-sqrt($part_nr+1)) / $scale_max * $max_iter;
                my $index_base = keys %gradient_mapping;
                $gradient_mapping{$index_base + $_} = $part_nr for 0 .. $gradient_part_length - 1;
            }
        } elsif ($set->{'mapping'}{'scale_distro'} eq 'cubert'){
            my $third = 1/3;
            my $scale_max = ($set->{'mapping'}{'scale_parts'}+1) ** $third;
            for my $part_nr (@all_but_not_last_part) {
                my $gradient_part_length = ((($part_nr+2)**$third) - (($part_nr+1)**$third)) / $scale_max * $max_iter;
                my $index_base = keys %gradient_mapping;
                $gradient_mapping{$index_base + $_} = $part_nr for 0 .. $gradient_part_length - 1;
            }
        } elsif ($set->{'mapping'}{'scale_distro'} eq 'log'){
            my $scale_max = log ($set->{'mapping'}{'scale_parts'}+1);
            for my $part_nr (@all_but_not_last_part) {
                my $gradient_part_length = (log($part_nr+2) - log($part_nr+1)) / $scale_max * $max_iter;
                my $index_base = keys %gradient_mapping;
                $gradient_mapping{$index_base + $_} = $part_nr for 0 .. $gradient_part_length - 1;
            }
        } elsif ($set->{'mapping'}{'scale_distro'} eq 'exp'){
            my $scale_max = exp ($set->{'mapping'}{'scale_parts'});
            for my $part_nr (@all_but_not_last_part) {
                my $gradient_part_length = (exp($part_nr+1) - exp($part_nr)) / $scale_max * $max_iter;
                my $index_base = keys %gradient_mapping;
                $gradient_mapping{$index_base + $_} = $part_nr for 0 .. $gradient_part_length - 1;
            }
        }
        my $index_base = keys %gradient_mapping;
        $gradient_mapping{$_} = $last_part_nr for $index_base .. $max_iter - 1;
    } else {
        $gradient_total_length = $max_iter;
    }

    if ($set->{'mapping'}{'user_colors'}){
        my $begin_nr = substr $set->{'mapping'}{'begin_color'}, 6;
        my $end_nr = substr $set->{'mapping'}{'end_color'}, 6;
        my $gradient_bases = 1 + abs( $begin_nr - $end_nr );

        my $gradient_part_length = ($gradient_bases == 1)
                                 ?  $gradient_total_length
                                 : int($gradient_total_length / ($gradient_bases - 1 ));
        my $gradient_direction = ( $begin_nr <= $end_nr ) ? 1 : -1;
        my $color_nr = $begin_nr;
        @gradient = map {color( $set->{'color'}{$color_nr} )} 1 .. $gradient_total_length if $gradient_bases == 1;
        for (1 .. $gradient_bases - 1) {
            my $start_color = color( $set->{'color'}{$color_nr} );
            $color_nr += $gradient_direction;
            # last partial gradient has to full it up to the end
            $gradient_part_length = $gradient_total_length - @gradient if $color_nr == $end_nr;
            push @gradient, $start_color->gradient( to => $set->{'color'}{$color_nr}, steps => $gradient_part_length,
                                                    in => $set->{'mapping'}{'gradient_space'},
                                               dynamic => $set->{'mapping'}{'gradient_dynamic'} );
            pop @gradient if $color_nr != $end_nr;
        }
        $background_color = (substr($set->{'mapping'}{'background_color'}, 0, 5) eq 'color')
                          ? $set->{'color'}{'1'}
                          : $set->{'mapping'}{'background_color'};
        $background_color = '#001845' if $background_color eq 'blue';
        $background_color = color( $background_color );
    } else {
        @gradient = color('white')->gradient( to => 'black', steps => $max_iter,
                                              in => $set->{'mapping'}{'gradient_space'},
                                         dynamic => $set->{'mapping'}{'gradient_dynamic'} );
        $background_color = $gradient[ -1 ];
    }

    @color = map { [$_->values( 'RGB' )] } @gradient;
    if (%gradient_mapping){
        my @temp_c = @color;
        $color[$_] = $temp_c[ $gradient_mapping{$_} ] for 0 .. $max_iter-1;
    }
    $background_color = [ $background_color->values( 'RGB' ) ];

    if ($set->{'mapping'}{'use_subgradient'}){

    }

    return \@color, $background_color;
}

sub from_settings {
    my( $set, $size, $progress_bar, $sketch ) = @_;
    my $img = Wx::Image->new( $size->{'x'}, $size->{'y'} );
    my $sketch_factor = (defined $sketch) ? SKETCH_FACTOR : 0;

    my $t0 = Benchmark->new();

    my $max_iter  =  int $set->{'constraint'}{'stop_nr'} ** 2;
    my $max_value =  $set->{'constraint'}{'stop_value'} ** 2;
    my $zoom      = 140 * $set->{'constraint'}{'zoom'};
    my $schranke  = $max_value ** 2;

    my ($colors, $background_color) = colors( $set, $max_iter );

    my $max_pixel_x  = $size->{x}-1;
    my $max_pixel_y  = $size->{y}-1;
    my $offset_x = (- $size->{'x'} / 2 / $zoom) + $set->{'constraint'}{'center_x'};
    my $offset_y = (- $size->{'y'} / 2 / $zoom) + $set->{'constraint'}{'center_y'};
    my $delta_x  = 1 / $zoom;
    my $delta_y  = 1 / $zoom;
    my $start_a  = $set->{'constraint'}{'start_a'};
    my $start_b  = $set->{'constraint'}{'start_b'};
    my $const_a  = $set->{'constraint'}{'const_a'};
    my $const_b  = $set->{'constraint'}{'const_b'};
    if ($sketch_factor){
        $delta_x *= $sketch_factor;
        $delta_y *= $sketch_factor;
        $max_pixel_x  /= $sketch_factor;
        $max_pixel_y  /= $sketch_factor;
    }

    my ($z_a_q, $z_b_q, $color, $px, $py, $metrik);
    my $x = $offset_x;

    my @paint_code;
    if ($sketch_factor){
        push @paint_code, '    $px = $pixel_x * '.$sketch_factor, '    $py = $pixel_y * '.$sketch_factor;
        for my $x (0 .. $sketch_factor -1){
            for my $y (0 .. $sketch_factor -1){
                push @paint_code, '    $img->SetRGB( $px+'.$x.', $py+'.$y.', @$color)';
            }
        }
    } else {
        push @paint_code, '    $img->SetRGB( $pixel_x, $pixel_y, @$color)';
    }
    my $metric_code = {
        '|var|' => '$z_a_q + $z_b_q', '|x*y|' => 'abs($z_a*$z_b)',
          '|x|' => 'abs($z_a)',         '|y|' => 'abs($z_b)',
        '|x+y|' => 'abs($z_a+$z_b)','|x|+|y|' => 'abs($z_b)+abs($z_b)',
         'x+y'  => '$z_a+$z_b',        'x*y'  => '$z_a*$z_b',
         'x-y'  => '$z_a-$z_b',        'y-x'  => '$z_b-$z_a'}->{ $set->{'constraint'}{'stop_metric'} };

    my @code = (
        'for my $pixel_x (0 .. $max_pixel_x){',
        '  my $y = $offset_y',
        '  for my $pixel_y (0 .. $max_pixel_y){',
       ($set->{'constraint'}{'coor_as_start'} ?
        '    my ($z_a, $z_b) = ($start_a+$x, $start_b+$y)' :
        '    my ($z_a, $z_b) = ($start_a, $start_b)' ),
        '    $color = $background_color',
        '    for my $i (0 .. $max_iter - 1){',
        '      $z_a_q = $z_a * $z_a',
        '      $z_b_q = $z_b * $z_b',
        '      $metrik = '.$metric_code,
        #'      say " ", sqrt($metrik - $schranke) if $metrik > $schranke',
        '      $color = $colors->[ $i ], last if $metrik >= $schranke',
        '      ($z_a, $z_b) = ($z_a_q - $z_b_q, 2 * $z_a * $z_b)',
        ($set->{'constraint'}{'coor_as_const'} ?
       ('      $z_a += $x + '.$const_a, '      $z_b += $y + '.$const_b) :
       ('      $z_a += '.$const_a,      '      $z_b += '.$const_b     ) ),
        '    }', @paint_code,
        '    $y += $delta_y',
        '  }',
        '  $x += $delta_x',
        '}',
    );

    my $code = join '', map { $_ . ";\n"} @code;
    eval $code;
    die "bad iter code - $@ :\n$code" if $@; # say $code;
    say "compile:",timestr(timediff(Benchmark->new, $t0));

    return $img;
}

1;

__END__

    my %factor = ();
    my $max_exp;
    for my $mnr (1 .. 4){
        my $set = $set->{'monomial_'.$mnr};
        next unless $set->{'active'};
        my $f = $set->{'use_factor'} ? [$set->{'factor_r'}, $set->{'factor_i'}] : [1,1];
        if (exists $factor{ $set->{'exponent'}}) {
            $factor{ $set->{'exponent'} }[0] *= $f->[0];
            $factor{ $set->{'exponent'} }[1] *= $f->[1];
        } else { $factor{ $set->{'exponent'} } = $f }
        $max_exp = $set->{'exponent'} unless defined $max_exp;
        $max_exp = $set->{'exponent'} if $max_exp < $set->{'exponent'};
    }
    $max_exp = 0 unless defined $max_exp;

    my $zoom_size = 4 * (10** (-$set->{'constraints'}{'zoom'}));
    my $stop = $set->{'constraints'}{'stop_value'};
    my $x_delta = $zoom_size;
    my $x_delta_step = $x_delta / $self->{'size'}{'x'};
    my $x_min = $set->{'constraints'}{'pos_x'} - ($x_delta / 2);
    my $y_delta = $zoom_size;
    my $y_delta_step = $y_delta / $self->{'size'}{'y'};
    my $y_min = $set->{'constraints'}{'pos_y'} - ($y_delta / 2);
    # my $const_a = ($set->{'constraints'}{'constant'} eq 'constant') ? $set->{'constraints'}{'const_a'} : 0;
    # my $const_b = ($set->{'constraints'}{'constant'} eq 'constant') ? $set->{'constraints'}{'const_b'} : 0;
    my $const_a = 0;
    my $const_b = 0;
    $const_a *= $factor{0}[0] if exists $factor{0} and $factor{0}[0];
    $const_b *= $factor{0}[1] if exists $factor{0} and $factor{0}[1];
    my $position = $set->{'constraints'}{'coordinates_use'};
    $position = substr($position, 7) if substr($position, 0, 7) eq 'degree ';
    if ($position =~ /\d/){
        $max_exp = $position if $max_exp < $position;
    }

    my $metric = { '|var|' => '($x*$x) + ($y*$y)', '|x*y|' => 'abs($x*$y)',
                     '|x|' => 'abs($x)',             '|y|' => 'abs($y)',
                   '|x+y|' => 'abs($x+$y)',      '|x|+|y|' => 'abs($x)+abs($y)',
                    'x+y'  => '$x+$y',              'x*y'  => '$x*$y',
                    'x-y'  =>     '$x-$y',          'y-x'  => '$y-$x'}->{ $set->{'constraints'}{'stop_metric'} };

    my @bg_color = ($set->{'mapping'}{'color'} and $set->{'mapping'}{'use_bg_color'})
                 ? color( $set->{'mapping'}{'background_color'} )->values( in => 'RGB', as=>'list' )
                 : (0,0,0);
    my $background_color = Wx::Colour->new( @bg_color );
    $dc->SetBackground( Wx::Brush->new( $background_color, &Wx::wxBRUSHSTYLE_SOLID ) );
    $dc->Clear();  # return $dc;

    # compute color gradient
    my $colors = ($set->{'mapping'}{'select'}-1) * ($set->{'mapping'}{'gradient'}+1)
                 * $set->{'mapping'}{'repeat'}    * $set->{'mapping'}{'grading'};
    my @color = ();
    if ($set->{'mapping'}{'color'}){
        $set->{'color'}{ $set->{'mapping'}{'select'} } = $set->{'color'}{ 8 };
        for my $color_i (1 .. $set->{'mapping'}{'select'} - 1) {
            my @gradient = map {[$_->values]}
                           color($set->{'color'}{$color_i})->gradient( to => $set->{'color'}{$color_i},
                                                                    steps => $set->{'mapping'}{'gradient'}+2,
                                                                  dynamic => $set->{'mapping'}{'dynamics'},
            );
            pop @gradient;
            @color = (@color, @gradient);
        }
    } else {
        @color = map {[$_->values]} color('white')->gradient( to => 'black',
                                                           steps => $set->{'mapping'}{'select'} * ($set->{'mapping'}{'gradient'}+2),
                                                         dynamic => $set->{'mapping'}{'dynamics'},
        );
    }
    my $subgradient = int($set->{'mapping'}{'grading'} > 1 and $set->{'mapping'}{'grading_type'} eq 'Group');
    if ($subgradient){
        my @temp = @color;
        @color = ();
        for my $color (@temp){
            push @color, $color for 1 .. $set->{'mapping'}{'grading'};
        }
    }
    if ($set->{'mapping'}{'repeat'} > 1){
        my @temp = @color;
        @color = (@color, @temp) for 2 .. $set->{'mapping'}{'repeat'};
    }
    if ($self->{'flag'}{'draw'}){
        $progress_bar->add_percentage( $_ / $#color * 100, $color[$_] ) for 0 .. $#color;
        $progress_bar->full;
    }

    if ($set->{'mapping'}{'grading'} > 1 and $set->{'mapping'}{'grading_type'} eq 'Sub' and not $self->{'flag'}{'sketch'}){
        for my $color_i (0 .. $#color){
            my $next = ($color_i == $#color) ? color( @bg_color ) : color( $color[$color_i+1] ) ;
            my @c = color( $color[$color_i] )->gradient( to => $next,
                                                      steps => $set->{'mapping'}{'grading'}+2,
                                                    dynamic => $set->{'mapping'}{'dynamics'},
            );
            pop @c;
            $color[$color_i] = [@c];
        }
    }
        if ($self->{'flag'}{'sketch'}){
        $x_delta_step *= SKETCH_FACTOR;
        $y_delta_step *= SKETCH_FACTOR;
        $colors = 25 if $colors > 25;
        $stop = 50 if $stop > 50;
    }
    my ($x_const, $y_const, $x, $y, $x_old, $y_old, $x_pot, $y_pot);
    my $last_color = $colors - 1;

    my ($x_const, $y_const, $x, $y, $x_old, $y_old, $x_pot, $y_pot);
    my $last_color = $colors - 1;

    my $code = 'my ($x_num, $x_pix) = ($x_min, 0);'."\n";
    $code .= $self->{'flag'}{'sketch'}
           ? 'for (0 .. $self->{size}{x} / SKETCH_FACTOR){'."\n"
           : 'for (0 .. $self->{size}{x}){'."\n";
    $code .= '  my ($y_num, $y_pix) = ($y_min, $self->{size}{y});'."\n";
    $code .= $self->{'flag'}{'sketch'}
           ? '  for (0 .. $self->{size}{y} / SKETCH_FACTOR){'."\n"
           : '  for (0 .. $self->{size}{y}){'."\n";

    my $x_start_value = ($set->{'constraints'}{'constant'} eq 'start value') ? $set->{'constraints'}{'const_a'} : 0;
    my $y_start_value = ($set->{'constraints'}{'constant'} eq 'start value') ? $set->{'constraints'}{'const_b'} : 0;

    if ($position eq 'start value'){
        $x_start_value = $x_start_value ? $x_start_value . ' + $x_num' : '$x_num';
        $y_start_value = $y_start_value ? $y_start_value . ' + $y_num' : '$y_num';
    }

    my %vals;
    $code .= '    $x = '.$x_start_value.';'."\n";
    $code .= '    $y = '.$y_start_value.';'."\n";
    $code .= '    for my $i (0 .. '.$last_color.'){'."\n";
    $code .= '      $x_pot = $x_old = $x;'."\n";
    $code .= '      $y_pot = $y_old = $y;'."\n";
    $code .= '      $x = '.(($position eq 'constant') ? $const_a.'+ $x_num' : $const_a).';'."\n";
    $code .= '      $y = '.(($position eq 'constant') ? $const_b.'+ $y_num' : $const_b).';'."\n";

    for my $exponent (2 .. $max_exp){
        $code .= '      ($x_pot, $y_pot) = (($x_pot * $x_old) - ($y_pot * $y_old), ($x_pot * $y_old) + ($x_old * $y_pot));'."\n";
        my $x_factor = (exists $factor{$exponent} and $factor{$exponent}[0]) ? ' * '.$factor{$exponent}[0] : '';
        my $y_factor = (exists $factor{$exponent} and $factor{$exponent}[1]) ? ' * '.$factor{$exponent}[1] : '';
        if ($position eq $exponent){
            $x_factor .= ' * $x_num';
            $y_factor .= ' * $y_num';
        }
        $code .= '      $x += $x_pot '.$x_factor.';'."\n" if $x_factor;
        $code .= '      $y += $y_pot '.$y_factor.';'."\n" if $y_factor;
