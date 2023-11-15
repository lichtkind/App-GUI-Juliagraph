use v5.12;
use warnings;
use Wx;

package App::GUI::Juliagraph::Frame::Part::Board;
use base qw/Wx::Panel/;
my $TAU = 6.283185307;

use constant SKETCH_FACTOR => 4;

use Graphics::Toolkit::Color;
use Benchmark;

sub new {
    my ( $class, $parent, $x, $y ) = @_;
    my $self = $class->SUPER::new( $parent, -1, [-1,-1], [$x, $y] );
    $self->{'menu_size'} = 27;
    $self->{'size'}{'x'} = $x;
    $self->{'size'}{'y'} = $y;
    $self->{'center'}{'x'} = $x / 2;
    $self->{'center'}{'y'} = $y / 2;
    $self->{'hard_radius'} = ($x > $y ? $self->{'center'}{'y'} : $self->{'center'}{'x'}) - 25;
    $self->{'dc'} = Wx::MemoryDC->new( );
    $self->{'bmp'} = Wx::Bitmap->new( $self->{'size'}{'x'} + 10, $self->{'size'}{'y'} +10 + $self->{'menu_size'}, 24);
    $self->{'dc'}->SelectObject( $self->{'bmp'} );

    Wx::Event::EVT_PAINT( $self, sub {
        my( $self, $event ) = @_;
        return unless ref $self->{'data'};
        $self->{'x_pos'} = $self->GetPosition->x;
        $self->{'y_pos'} = $self->GetPosition->y;

        if (exists $self->{'new'}) {
            $self->{'dc'}->Blit (0, 0, $self->{'size'}{'x'} + $self->{'x_pos'},
                                       $self->{'size'}{'y'} + $self->{'y_pos'} + $self->{'menu_size'},
                                       $self->paint( Wx::PaintDC->new( $self ), $self->{'size'}{'x'}, $self->{'size'}{'y'} ), 0, 0);
        } else {
            Wx::PaintDC->new( $self )->Blit (0, 0, $self->{'size'}{'x'},
                                                   $self->{'size'}{'y'} + $self->{'menu_size'},
                                                   $self->{'dc'},
                                                   $self->{'x_pos'} , $self->{'y_pos'} + $self->{'menu_size'} );
        }
        1;
    }); # Blit (xdest, ydest, width, height, DC *src, xsrc, ysrc, wxRasterOperationMode logicalFunc=wxCOPY, bool useMask=false)
    # Wx::Event::EVT_LEFT_DOWN( $self->{'board'}, sub {});

    return $self;
}

sub set_data {
    my( $self, $data ) = @_;
    return unless ref $data eq 'HASH';
    $self->{'data'} = $data;
    $self->{'new'} = 1;
}

sub set_sketch_flag { $_[0]->{'sketch'} = 1 }


sub paint {
    my( $self, $dc, $width, $height ) = @_;
    my $background_color = Wx::Colour->new( 255, 255, 255 );
    $dc->SetBackground( Wx::Brush->new( $background_color, &Wx::wxBRUSHSTYLE_SOLID ) );
    $dc->Clear();

    my $colors = $self->{'data'}{'mapping'}{'shades'};
    # my $col_factor = int($colors / log($colors) );
    my @color = map {Wx::Colour->new( $_, $_, $_ )} map { $_ * $self->{'data'}{'mapping'}{'grouping'} } 0 .. $colors;
    my @gray = map { $_ * $self->{'data'}{'mapping'}{'grouping'} } 0 .. $colors;

    my $zoom_size = 4 * (10** (-$self->{'data'}{'form'}{'zoom'}));
    my $stop = $self->{'data'}{'form'}{'stop_value'};
    my $const_a = $self->{'data'}{'form'}{'const_a'};
    my $const_b = $self->{'data'}{'form'}{'const_b'};
    my $var_c = $self->{'data'}{'form'}{'var_c'};
    my $var_d = $self->{'data'}{'form'}{'var_d'};
    my $x_delta = $zoom_size;
    my $x_delta_step = $x_delta / $self->{'size'}{'x'};
    my $x_min = $self->{'data'}{'form'}{'pos_x'} - ($x_delta / 2);
    my $y_delta = $zoom_size;
    my $y_delta_step = $y_delta / $self->{'size'}{'y'};
    my $y_min = $self->{'data'}{'form'}{'pos_y'} - ($y_delta / 2);

    my $metric = { '|var|' => '($x*$x) + ($y*$y)', '|x|' => 'abs($x)', '|y|' => 'abs($y)',
                   '|x+y|' => 'abs($x+$y)',    '|x|+|y|' => 'abs($x)+abs($y)', 'x+y' => '$x+$y',
                    'x*y'  => '$x*$y',           '|x*y|' => 'abs($x*$y)',
                    'x-y' => '$x-$y', 'y-x' => '$y-$x',
    };
    if ($self->{'sketch'}){
        $x_delta_step *= SKETCH_FACTOR;
        $y_delta_step *= SKETCH_FACTOR;
    }

    my $t0 = Benchmark->new();
    my $img = Wx::Image->new($self->{'size'}{'x'},$self->{'size'}{'y'});
    my ($x_const, $y_const, $x, $y, $x_old, $y_old, $r, $g, $b);

    my $code = 'my ($x_num, $x_pix) = ($x_min, 0);'."\n";
    $code .= $self->{'sketch'}
           ? 'for (0 .. $self->{size}{x} / SKETCH_FACTOR){'."\n"
           : 'for (0 .. $self->{size}{x}){'."\n";
    $code .= '  my ($y_num, $y_pix) = ($y_min, $self->{size}{y});'."\n";
    $code .= $self->{'sketch'}
           ? '  for (0 .. $self->{size}{y} / SKETCH_FACTOR){'."\n"
           : '  for (0 .. $self->{size}{y}){'."\n";
    $code .= ($self->{'data'}{'form'}{'type'} eq 'Julia')
           ? '    ($x, $y) = ($x_num, $y_num);'."\n".
             '    ($x_const, $y_const) = ($const_a, $const_b);'."\n"
           : '    ($x, $y) = ($const_a, $const_b);'."\n".
             '    ($x_const, $y_const) = ($x_num, $y_num);'."\n";
    $code .= '    for my $i (0 .. $colors){'."\n";
    $code .= '      $x_old = $x;'."\n";
    $code .= '      $y_old = $y;'."\n";
    $code .= '      ($x, $y) = (($x * $x_old) - ($y * $y_old), ($x * $y_old) + ($x_old * $y));'."\n" for 2 .. $self->{'data'}{'form'}{'exp'};
    $code .= '      $x += $x_old * $var_c;'."\n" if $var_c;
    $code .= '      $y += $y_old * $var_d;'."\n" if $var_d;
    $code .= '      $x += $x_const;'."\n";
    $code .= '      $y += $y_const;'."\n";
    $code .= '      if ('.$metric->{$self->{'data'}{'form'}{'stop_metric'}}.' > $stop){'."\n";
    $code .= '        ($r, $g, $b) = ($gray[$i], $gray[$i], $gray[$i]);'."\n";
    $code .= '        $img->SetRGB( $x_pix,   $y_pix,   $r, $g, $b);'."\n";
    $code .= '        $img->SetRGB( $x_pix,   $y_pix+1, $r, $g, $b);'."\n".
             '        $img->SetRGB( $x_pix+1, $y_pix,   $r, $g, $b);'."\n".
             '        $img->SetRGB( $x_pix+1, $y_pix+1, $r, $g, $b);'."\n".
             '        $img->SetRGB( $x_pix+1, $y_pix+2, $r, $g, $b);'."\n".
             '        $img->SetRGB( $x_pix+2, $y_pix+1, $r, $g, $b);'."\n" if $self->{'sketch'};
    $code .= '        last;'."\n".'      }'."\n".'    }'."\n";
    $code .= '    $y_num += $y_delta_step;'."\n";
    $code .= $self->{'sketch'}
           ? '    $y_pix -= SKETCH_FACTOR;'."\n"
           : '    $y_pix --;'."\n";
    $code .= '  }'."\n";
    $code .= '  $x_num += $x_delta_step;'."\n";
    $code .= $self->{'sketch'}
           ? '  $x_pix += SKETCH_FACTOR;'."\n"
           : '  $x_pix ++;'."\n";
    $code .= '}'."\n";

    eval $code; # say $code;
    die "bad iter code - $@ :\n$code" if $@; # say "comp: ",timestr( timediff( Benchmark->new(), $t) );

    say "compute:",timestr(timediff(Benchmark->new, $t0));
    $t0 = Benchmark->new();

    $dc->DrawBitmap( Wx::Bitmap->new( $img ), 0, 0, 0 );
    $self->{'image'} = $img unless $self->{'sketch'};

    delete $self->{'new'};
    delete $self->{'sketch'};
    $dc;
}

sub save_file {
    my( $self, $file_name, $width, $height ) = @_;
    my $file_end = lc substr( $file_name, -3 );
    if ($file_end eq 'svg') { $self->save_svg_file( $file_name, $width, $height ) }
    elsif ($file_end eq 'png' or $file_end eq 'jpg') { $self->save_bmp_file( $file_name, $file_end, $width, $height ) }
    else { return "unknown file ending: '$file_end'" }
}

sub save_svg_file {
    my( $self, $file_name, $width, $height ) = @_;
    $width  //= $self->GetParent->{'config'}->get_value('image_size');
    $height //= $self->GetParent->{'config'}->get_value('image_size');
    $width  //= $self->{'size'}{'x'};
    $height //= $self->{'size'}{'y'};
    my $dc = Wx::SVGFileDC->new( $file_name, $width, $height, 250 );  #  250 dpi
    $self->paint( $dc, $width, $height );
}

sub save_bmp_file {
    my( $self, $file_name, $file_end, $width, $height ) = @_;
    $width  //= $self->GetParent->{'config'}->get_value('image_size');
    $height //= $self->GetParent->{'config'}->get_value('image_size');
    $width  //= $self->{'size'}{'x'};
    $height //= $self->{'size'}{'y'};
    # reuse $self->{'data'}{'image'}
    my $bmp = Wx::Bitmap->new( $width, $height, 24); # bit depth
    my $dc = Wx::MemoryDC->new( );
    $dc->SelectObject( $bmp );
    $self->paint( $dc, $width, $height);
    # $dc->Blit (0, 0, $width, $height, $self->{'dc'}, 10, 10 + $self->{'menu_size'});
    $dc->SelectObject( &Wx::wxNullBitmap );
    $bmp->SaveFile( $file_name, $file_end eq 'png' ? &Wx::wxBITMAP_TYPE_PNG : &Wx::wxBITMAP_TYPE_JPEG );
}

1;

__END__
