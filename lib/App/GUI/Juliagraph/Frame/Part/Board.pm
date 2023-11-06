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
    my $background_color = Wx::Colour->new( 0, 0, 0 );
    $dc->SetBackground( Wx::Brush->new( $background_color, &Wx::wxBRUSHSTYLE_SOLID ) );
    $dc->Clear();

    my $stop = 255;
    my @c = map {Wx::Colour->new( $stop-$_, $stop-$_, $stop-$_ )} 0 .. $stop;
    my $sketch_factor = 4;
    my $t0 = Benchmark->new();
    if ($self->{'data'}{'sketch'}){
        for my $xp (0 .. $self->{'size'}{'x'}/$sketch_factor){
            my $x = -2 + (4 * $sketch_factor * $xp / $self->{'size'}{'x'});
            for my $yp (0 .. $self->{'size'}{'y'}/$sketch_factor){
                my $y = -2 + (4*$sketch_factor * $yp / $self->{'size'}{'y'});
                my ($xi, $yi) = ($x, $y);
                for my $i (0 .. 255){
                    ($xi, $yi) = ( ($xi * $xi) - ($yi * $yi) +$x, (2 * $xi * $yi) +$y);
                    #last if $xi == 0 and $yi == 0;
                    if ((($xi*$xi) + ($yi*$yi)) > 1000){
                        $dc->SetPen( Wx::Pen->new( $c[$i], $sketch_factor, &Wx::wxPENSTYLE_SOLID) );
                        $dc->DrawPoint( $xp * $sketch_factor, $yp * $sketch_factor );
                        last;
                    }
                }
            }
        }
    } else {
        for my $xp (0 .. $self->{'size'}{'x'}){
            my $x = -2 + (4 * $xp / $self->{'size'}{'x'});
            for my $yp (0 .. $self->{'size'}{'y'}){
                my $y = -2 + (4 * $yp / $self->{'size'}{'y'});
                my ($xi, $yi) = ($x, $y);
                for my $i (0 .. 255){
                    ($xi, $yi) = ( ($xi * $xi) - ($yi * $yi) +$x, (2 * $xi * $yi) +$y);
                    #last if $xi == 0 and $yi == 0;
                    if ((($xi*$xi) + ($yi*$yi)) > 1000){
                        $dc->SetPen( Wx::Pen->new( $c[$i], 1, &Wx::wxPENSTYLE_SOLID) );
                        $dc->DrawPoint( $xp, $yp );
                        last;
                    }
                }
            }
        }
    }
    say "julia took:",timestr(timediff(Benchmark->new, $t0));
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

# https://developer.mozilla.org/en-US/docs/Web/SVG/Element#shape_elements <polyline>
