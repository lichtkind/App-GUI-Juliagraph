use v5.12;
use warnings;
use Wx;

package App::GUI::Juliagraph::Frame::Part::Board;
use base qw/Wx::Panel/;
my $TAU = 6.283185307;

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

        if (exists $self->{'data'}{'new'}) {
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
    $self->{'data'}{'new'} = 1;
}

sub set_sketch_flag { $_[0]->{'data'}{'sketch'} = 1 }


sub paint {
    my( $self, $dc, $width, $height ) = @_;
    my $background_color = Wx::Colour->new( 255, 255, 255 );
    $dc->SetBackground( Wx::Brush->new( $background_color, &Wx::wxBRUSHSTYLE_SOLID ) );
    $dc->Clear();

    my $sketch_factor = 4;

    my $zoom_size = 4 * (10** (-$self->{'data'}{'form'}{'zoom'}));
    my $stop = $self->{'data'}{'form'}{'stop'};
    my $colors = $self->{'data'}{'form'}{'shades'};
    my $col_factor = int($colors / log($colors) );
    my @color = map {Wx::Colour->new( $_, $_, $_ )} map { $_ * 25 } 0 .. $colors; #map { $_ ? (log($_) * $col_factor) : 0 }
    my $const_a = $self->{'data'}{'form'}{'const_a'};
    my $const_b = $self->{'data'}{'form'}{'const_b'};
    my $x_delta = $zoom_size;
    my $x_delta_step = $x_delta / $self->{'size'}{'x'};
    my $x_min = $self->{'data'}{'form'}{'pos_x'} - ($x_delta / 2);
    my $y_delta = $zoom_size;
    my $y_delta_step = $y_delta / $self->{'size'}{'y'};
    my $y_min = $self->{'data'}{'form'}{'pos_y'} - ($y_delta / 2);
    my ($x_var, $y_var, $x_const, $y_const, $type);
    if ($self->{'data'}{'form'}{'type'} eq 'Julia'){
        $x_const = $const_a;
        $y_const = $const_b;
        $type = 1;
    } else {
        $x_var = $const_a;
        $y_var = $const_b;
        $type = 0;
    }
    my $t0 = Benchmark->new();
    my @pen = $self->{'data'}{'sketch'}
            ? (map {Wx::Pen->new( $color[$_], $sketch_factor+1, &Wx::wxPENSTYLE_SOLID)} 0 .. $colors)
            : (map {Wx::Pen->new( $color[$_], 1, &Wx::wxPENSTYLE_SOLID)} 0 .. $colors);
    if ($self->{'data'}{'sketch'}){
        $x_delta_step *= $sketch_factor;
        $y_delta_step *= $sketch_factor;
        delete $self->{'data'}{'pixel'};

        if ($type){ # Julia sketch
            my $x_num = $x_min;
            my $x_pix = 0;
            for (0 .. $self->{'size'}{'x'} / $sketch_factor){
                my $y_num = $y_min;
                my $y_pix = $self->{'size'}{'y'};
                for (0 .. $self->{'size'}{'y'} / $sketch_factor){
                    my ($x_it, $y_it) = ($x_num, $y_num);
                    for my $i (0 .. $colors){
                        ($x_it, $y_it) = ( ($x_it * $x_it) - ($y_it * $y_it) + $x_const, (2 * $x_it * $y_it) + $y_const);
                        if ((($x_it*$x_it) + ($x_it * $x_it)) > $stop){
                            $dc->SetPen( $pen[$i] );
                            $dc->DrawPoint( $x_pix, $y_pix);
                            last;
                        }
                    }
                    $y_num += $y_delta_step;
                    $y_pix -= $sketch_factor;
                }
                $x_num += $x_delta_step;
                $x_pix += $sketch_factor;
            }
        } else { # Mandelbrot sketch
            my $x_num = $x_min;
            my $x_pix = 0;
            for (0 .. $self->{'size'}{'x'} / $sketch_factor){
                my $y_num = $y_min;
                my $y_pix = $self->{'size'}{'y'};
                for (0 .. $self->{'size'}{'y'} / $sketch_factor){
                    my ($x_it, $y_it) = ($const_a, $const_b);
                    ($x_const, $y_const) = ($x_num, $y_num);
                    for my $i (0 .. $colors){
                        ($x_it, $y_it) = ( ($x_it * $x_it) - ($y_it * $y_it) + $x_const, (2 * $x_it * $y_it) + $y_const);
                        if ((($x_it*$x_it) + ($x_it * $x_it)) > $stop){
                            $dc->SetPen( $pen[$i] );
                            $dc->DrawPoint( $x_pix, $y_pix);
                            last;
                        }
                    }
                    $y_num += $y_delta_step;
                    $y_pix -= $sketch_factor;
                }
                $x_num += $x_delta_step;
                $x_pix += $sketch_factor;
            }
        }
        say "sketch:",timestr(timediff(Benchmark->new, $t0));
    } else {
        my $pixel = [];

        if ($type){ # Julia draw
            my $x_num = $x_min;
            my $x_pix = 0;
            for (0 .. $self->{'size'}{'x'}){
                my $y_num = $y_min;
                my $y_pix = 0;
                for (0 .. $self->{'size'}{'y'}){
                    my ($x_it, $y_it) = ($x_num, $y_num);
                    for my $i (0 .. $colors){
                        ($x_it, $y_it) = ( ($x_it * $x_it) - ($y_it * $y_it) + $x_const, (2 * $x_it * $y_it) + $y_const);
                        if ((($x_it*$x_it) + ($x_it * $x_it)) > $stop){
                            $pixel->[$x_pix][$y_pix] = $i;
                            last;
                        }
                    }
                    $y_num += $y_delta_step;
                    $y_pix ++;
                }
                $x_num += $x_delta_step;
                $x_pix ++;
            }
        } else { # Mandelbrot draw
            my $x_num = $x_min;
            my $x_pix = 0;
            for (0 .. $self->{'size'}{'x'}){
                my $y_num = $y_min;
                my $y_pix = $self->{'size'}{'y'};
                for (0 .. $self->{'size'}{'y'}){
                    my ($x_it, $y_it) = ($const_a, $const_b);
                    ($x_const, $y_const) = ($x_num, $y_num);
                    for my $i (0 .. $colors){
                        ($x_it, $y_it) = ( ($x_it * $x_it) - ($y_it * $y_it) + $x_const, (2 * $x_it * $y_it) + $y_const);
                        if ((($x_it*$x_it) + ($x_it * $x_it)) > $stop){
                            $pixel->[$x_pix][$y_pix] = $i;
                            last;
                        }
                    }
                    $y_num += $y_delta_step;
                    $y_pix --;
                }
                $x_num += $x_delta_step;
                $x_pix ++;
            }
        }

        say "compute:",timestr(timediff(Benchmark->new, $t0));
        my $pen_index = -1;
        $t0 = Benchmark->new();
        for my $x (0 .. $self->{'size'}{'x'}){
            for (0 .. $self->{'size'}{'y'}){
                next unless defined $pixel->[$x][$_];
                unless ($pen_index == $pixel->[$x][$_]){
                    $pen_index = $pixel->[$x][$_];
                    $dc->SetPen( $pen[$pen_index] );
                }
                $dc->DrawPoint( $x, $_ );
                #$dc->DrawRectangle( $x, $_, 1, 1 );
            }
        }
        say "draw:",timestr(timediff(Benchmark->new, $t0));
        $self->{'data'}{'pixel'} = $pixel;
    }

    delete $self->{'data'}{'new'};
    delete $self->{'data'}{'sketch'};
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
    my $bmp = Wx::Bitmap->new( $width, $height, 24); # bit depth
    my $dc = Wx::MemoryDC->new( );
    $dc->SelectObject( $bmp );
    $self->paint( $dc, $width, $height);
    # $dc->Blit (0, 0, $width, $height, $self->{'dc'}, 10, 10 + $self->{'menu_size'});
    $dc->SelectObject( &Wx::wxNullBitmap );
    $bmp->SaveFile( $file_name, $file_end eq 'png' ? &Wx::wxBITMAP_TYPE_PNG : &Wx::wxBITMAP_TYPE_JPEG );
}

1;
