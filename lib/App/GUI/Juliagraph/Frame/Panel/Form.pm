use v5.12;
use warnings;
use Wx;

package App::GUI::Juliagraph::Frame::Panel::Form;
use base qw/Wx::Panel/;
use App::GUI::Juliagraph::Widget::SliderStep;

sub new {
    my ( $class, $parent) = @_;
    my $self = $class->SUPER::new( $parent, -1);
    $self->{'callback'} = sub {};

    my $exp_lbl  = Wx::StaticText->new($self, -1, 'E x p :' );
    my $const_lbl  = Wx::StaticText->new($self, -1, 'C o n s t a n t :' );
    my $a_lbl  = Wx::StaticText->new($self, -1, 'A : ' );
    my $b_lbl  = Wx::StaticText->new($self, -1, 'B : ' );
    my $pos_lbl  = Wx::StaticText->new($self, -1, 'P o s i t i o n : ' );
    my $x_lbl  = Wx::StaticText->new($self, -1, 'X : ' );
    my $y_lbl  = Wx::StaticText->new($self, -1, 'Y : ' );
    my $zoom_lbl  = Wx::StaticText->new($self, -1, 'Z o o m : ' );
    my $stop_lbl  = Wx::StaticText->new($self, -1, 'S t o p : ' );
    my $shade_lbl  = Wx::StaticText->new($self, -1, 'S h a d e s : ' );
    my $scale_lbl  = Wx::StaticText->new($self, -1, 'S c a l i n g : ' );

    $self->{'type'}     = Wx::RadioBox->new( $self, -1, ' T y p e ', [-1,-1],[-1,-1], ['Julia','Mandelbrot'] );
    $self->{'const_a'}  = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'const_b'}  = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'pos_x'}    = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'pos_y'}    = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'zoom'}     = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [80, -1] );
    $self->{'button_a'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, '<<', '>>' );
    $self->{'button_b'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, '<<', '>>' );
    $self->{'button_x'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, '<<', '>>' );
    $self->{'button_y'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, '<<', '>>' );
    $self->{'button_zoom'} = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, '<<', '>>' );
    $self->{'exp'} = Wx::ComboBox->new( $self, -1, 2, [-1,-1],[65, 35], [2]); # .. 12
    $self->{'exp'}->SetToolTip('exponent of iterator variable');
    $self->{'stop'}   = Wx::ComboBox->new( $self, -1, 1000, [-1,-1],[95, -1], [50,100, 400, 1000, 3000, 10000]);
    $self->{'shades'} = Wx::ComboBox->new( $self, -1, 256, [-1,-1],[95, -1], [5, 8,12,15,20,30,45,65, 95, 130, 170, 210, 256]);
    $self->{'scaling'} = Wx::ComboBox->new( $self, -1, 25, [-1,-1],[95, -1], [1, 2, 3, 5, 8, 12, 17, 25, 30, 35]);

    $self->{'button_a'}->SetCallBack(sub { $self->{'const_a'}->SetValue( $self->{'const_a'}->GetValue + shift ) });
    $self->{'button_b'}->SetCallBack(sub { $self->{'const_b'}->SetValue( $self->{'const_b'}->GetValue + shift ) });
    $self->{'button_x'}->SetCallBack(sub { my $value = shift;$self->{'pos_x'}->SetValue( $self->{'pos_x'}->GetValue + ($value * $self->zoom_size) ) });
    $self->{'button_y'}->SetCallBack(sub { my $value = shift;$self->{'pos_y'}->SetValue( $self->{'pos_y'}->GetValue + ($value * $self->zoom_size) ) });
    $self->{'button_zoom'}->SetCallBack(sub { $self->{'zoom'}->SetValue( $self->{'zoom'}->GetValue + shift ) });

    Wx::Event::EVT_RADIOBOX( $self, $self->{'type'},  sub { $self->{'callback'}->() });
    Wx::Event::EVT_TEXT( $self, $self->{$_},          sub { $self->{'callback'}->() }) for qw/const_a const_b pos_x pos_y zoom/;
    Wx::Event::EVT_COMBOBOX( $self, $self->{$_},      sub { $self->{'callback'}->() }) for qw/exp stop shades scaling/;

    my $vert_prop = &Wx::wxALIGN_LEFT|&Wx::wxTOP|&Wx::wxBOTTOM|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxALIGN_CENTER_HORIZONTAL|&Wx::wxGROW;
    my $item_prop = &Wx::wxALIGN_LEFT|&Wx::wxLEFT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxALIGN_CENTER_HORIZONTAL|&Wx::wxGROW;
    my $txt_prop = &Wx::wxALIGN_LEFT|&Wx::wxLEFT|&Wx::wxRIGHT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxGROW;
    my $std_margin = 10;

    my $type_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $type_sizer->AddSpacer( $std_margin );
    $type_sizer->Add( $self->{'type'}, 0, $vert_prop, 10);
    $type_sizer->AddStretchSpacer( );
    $type_sizer->Add( $exp_lbl,          0, $vert_prop, 12);
    $type_sizer->AddSpacer( $std_margin );
    $type_sizer->Add( $self->{'exp'},     0, &Wx::wxALIGN_CENTER_VERTICAL, 0);
    $type_sizer->AddSpacer( 20 );

    my $a_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $a_sizer->AddSpacer( $std_margin );
    $a_sizer->Add( $a_lbl,          0, $vert_prop, 12);
    $a_sizer->AddSpacer( 5 );
    $a_sizer->Add( $self->{'const_a'},  1, $vert_prop, 0);
    $a_sizer->AddSpacer( 5 );
    $a_sizer->Add( $self->{'button_a'}, 0, $item_prop, 0);
    $a_sizer->AddSpacer( $std_margin );

    my $b_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $b_sizer->AddSpacer( $std_margin );
    $b_sizer->Add( $b_lbl,          0, $vert_prop, 12);
    $b_sizer->AddSpacer( 5 );
    $b_sizer->Add( $self->{'const_b'},  1, $vert_prop, 0);
    $b_sizer->AddSpacer( 5 );
    $b_sizer->Add( $self->{'button_b'}, 0, $item_prop, 0);
    $b_sizer->AddSpacer( $std_margin );

    my $x_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $x_sizer->AddSpacer( $std_margin );
    $x_sizer->Add( $x_lbl,          0, $vert_prop, 12);
    $x_sizer->AddSpacer( 5 );
    $x_sizer->Add( $self->{'pos_x'},  1, $vert_prop, 0);
    $x_sizer->AddSpacer( 5 );
    $x_sizer->Add( $self->{'button_x'}, 0, $item_prop, 0);
    $x_sizer->AddSpacer( $std_margin );

    my $y_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $y_sizer->AddSpacer( $std_margin );
    $y_sizer->Add( $y_lbl,          0, $vert_prop, 12);
    $y_sizer->AddSpacer( 5 );
    $y_sizer->Add( $self->{'pos_y'},  1, $vert_prop, 0);
    $y_sizer->AddSpacer( 5 );
    $y_sizer->Add( $self->{'button_y'}, 0, $item_prop, 0);
    $y_sizer->AddSpacer( $std_margin );

    my $zoom_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $zoom_sizer->AddSpacer( $std_margin );
    $zoom_sizer->Add( $self->{'zoom'},  1, $vert_prop, 0);
    $zoom_sizer->AddSpacer( 5 );
    $zoom_sizer->Add( $self->{'button_zoom'}, 0, $item_prop, 0);
    $zoom_sizer->AddSpacer( $std_margin );

    my $grain_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $grain_sizer->Add( $shade_lbl,  0, $item_prop, 0);
    $grain_sizer->AddSpacer( 10 );
    $grain_sizer->Add( $self->{'shades'},  0, $vert_prop, 0);
    $grain_sizer->Add( 0, 0, &Wx::wxEXPAND | &Wx::wxGROW);
    $grain_sizer->Add( $stop_lbl,  0, $item_prop, 0);
    $grain_sizer->AddSpacer( 10 );
    $grain_sizer->Add( $self->{'stop'},  0, $vert_prop, 0);
    $grain_sizer->AddSpacer( $std_margin );

    my $scale_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $scale_sizer->Add( $scale_lbl,  0, $item_prop, 0);
    $scale_sizer->AddSpacer( 10 );
    $scale_sizer->Add( $self->{'scaling'},  0, $vert_prop, 0);
    $scale_sizer->AddStretchSpacer( );
    $scale_sizer->AddSpacer( $std_margin );

    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
    $sizer->Add( $type_sizer,  0, $item_prop, 0);
    $sizer->AddSpacer( 10 );
    $sizer->Add( $const_lbl,  0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, $std_margin);
    $sizer->AddSpacer( 5 );
    $sizer->Add( $a_sizer,  0, $item_prop, 0);
    $sizer->AddSpacer( 20 );
    $sizer->Add( $b_sizer,  0, $item_prop, 0);
    $sizer->AddSpacer( 25 );
    $sizer->Add( $pos_lbl,  0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, $std_margin);
    $sizer->AddSpacer( 5 );
    $sizer->Add( $x_sizer,  0, $item_prop, 0);
    $sizer->AddSpacer( 20 );
    $sizer->Add( $y_sizer,   0, $item_prop, 0);
    $sizer->AddSpacer( 25 );
    $sizer->Add( $zoom_lbl,   0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, $std_margin);
    $sizer->AddSpacer( 5 );
    $sizer->Add( $zoom_sizer,  0, $item_prop, 0);
    $sizer->AddSpacer( 20 );
    $sizer->Add( $grain_sizer,  0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, $std_margin);
    $sizer->AddSpacer( 10 );
    $sizer->Add( $scale_sizer,  0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, $std_margin);
    $self->SetSizer($sizer);

    $self->init();
    $self;
}

sub init {
    my ( $self ) = @_;
    $self->set_data ({ type => 'Mandelbrot', const_a => 0, const_b => 0, exp => 2,
                       pos_x => 0, pos_y => 0, zoom => 0, shades => 256, stop => 1000, scaling => 25} );
}

sub get_data {
    my ( $self ) = @_;
    {
        type    => $self->{'type'}->GetString( $self->{'type'}->GetSelection ),
        const_a => $self->{'const_a'}->GetValue,
        const_b => $self->{'const_b'}->GetValue,
        pos_x   => $self->{'pos_x'}->GetValue,
        pos_y   => $self->{'pos_y'}->GetValue,
        zoom    => $self->{'zoom'}->GetValue,
        exp     => $self->{'exp'}->GetStringSelection,
        stop    => $self->{'stop'}->GetStringSelection,
        shades  => $self->{'shades'}->GetStringSelection,
        scaling => $self->{'scaling'}->GetStringSelection,
    }
}

sub set_data {
    my ( $self, $data ) = @_;
    return 0 unless ref $data eq 'HASH' and exists $data->{'pos_x'};
    $self->PauseCallBack();
    for my $key (qw/const_a const_b pos_x pos_y zoom/){
        next unless exists $data->{$key} and exists $self->{$key};
        $self->{$key}->SetValue( $data->{$key} );
    }
    for my $key (qw/type exp stop shades scaling/){
        next unless exists $data->{$key} and exists $self->{$key};
        $self->{$key}->SetSelection( $self->{$key}->FindString($data->{$key}) );
    }
    $self->RestoreCallBack();
    1;
}

sub zoom_size { 10 ** (-$_[0]->{'zoom'}->GetValue) }

sub SetCallBack {
    my ($self, $code) = @_;
    return unless ref $code eq 'CODE';
    $self->{'callback'} = $code;
}
sub PauseCallBack {
    my ($self) = @_;
    $self->{'pause'} = $self->{'callback'};
    $self->{'callback'} = sub {};
}
sub RestoreCallBack {
    my ($self) = @_;
    return unless exists $self->{'pause'};
    $self->{'callback'} = $self->{'pause'};
    delete $self->{'pause'};
}


1;
