
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
