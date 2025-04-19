
# drawing board

package App::GUI::Juliagraph::Frame::Panel::Board;
use v5.12;
use warnings;
use Wx;
use base qw/Wx::Panel/;
use App::GUI::Juliagraph::Compute::Image;

sub new {
    my ( $class, $parent, $x, $y ) = @_;
    my $self = $class->SUPER::new( $parent, -1, [-1,-1], [$x, $y] );
    $self->{'menu_size'} = 28;
    $self->{'size'}{'x'} = $x;
    $self->{'size'}{'y'} = $y;
    $self->{'center'}{'x'} = $x / 2;
    $self->{'center'}{'y'} = $y / 2;
    $self->{'dc'} = Wx::MemoryDC->new( );
    $self->{'bmp'} = Wx::Bitmap->new( $self->{'size'}{'x'} + 10, $self->{'size'}{'y'} +10 + $self->{'menu_size'}, 24);
    $self->{'dc'}->SelectObject( $self->{'bmp'} );

    Wx::Event::EVT_PAINT( $self, sub {
        my( $self, $event ) = @_;

        return unless ref $self->{'settings'};
        $self->{'x_pos'} = $self->GetPosition->x;
        $self->{'y_pos'} = $self->GetPosition->y;

        if (exists $self->{'flag'}{'new'}) {
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
  #  Wx::Event::EVT_ENTER_WINDOW( $self, sub {
   # });
  #  Wx::Event::EVT_LEFT_DOWN( $self, sub {
# say "left";
   # });
    #~ Wx::Event::EVT_MOTION( $self, sub {
 #~ say "move";
    #~ });
    #~ Wx::Event::EVT_LEFT_DCLICK( $self, sub {
 #~ say "double left";
   #~ });
    #~ Wx::Event::EVT_RIGHT_UP( $self, sub {
 #~ say "right";
   #~ });
    #~ Wx::Event::EVT_LEFT_UP( $self, sub {
    #~ });

    return $self;
}

sub draw {
    my( $self, $settings ) = @_;
    return unless $self->set_settings( $settings );
    $self->{'flag'}{'draw'} = 1;
    $self->Refresh;
}

sub sketch {
    my( $self, $settings ) = @_;
    return unless $self->set_settings( $settings );
    $self->{'flag'}{'sketch'} = 1;
    $self->Refresh;
}

sub set_settings {
    my( $self, $settings ) = @_;
    return unless ref $settings eq 'HASH';
    $self->{'settings'} = $settings;
    $self->{'flag'}{'new'} = 1;
}


sub paint {
    my( $self, $dc, $width, $height ) = @_;
    my $img = App::GUI::Juliagraph::Compute::Image::from_settings(
        $self->{'settings'}, $self->{'size'}, $self->{'flag'}{'sketch'},
    );
    $dc->DrawBitmap( Wx::Bitmap->new( $img ), 0, 0, 0 ); # at point (0, 0) with no mask
    $self->{'image'} = $img unless $self->{'flag'}{'sketch'};
    delete $self->{'flag'};
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
    # reuse $set->{'image'}
    my $bmp = Wx::Bitmap->new( $width, $height, 24); # bit depth
    my $dc = Wx::MemoryDC->new( );
    $dc->SelectObject( $bmp );
    $self->paint( $dc, $width, $height);
    # $dc->Blit (0, 0, $width, $height, $self->{'dc'}, 10, 10 + $self->{'menu_size'});
    $dc->SelectObject( &Wx::wxNullBitmap );
    $bmp->SaveFile( $file_name, $file_end eq 'png' ? &Wx::wxBITMAP_TYPE_PNG : &Wx::wxBITMAP_TYPE_JPEG );
}

1;
