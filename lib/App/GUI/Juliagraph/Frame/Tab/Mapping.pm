
# visible tab with all visual settings

package App::GUI::Juliagraph::Frame::Tab::Mapping;
use v5.12;
use warnings;
use base qw/Wx::Panel/;
use Graphics::Toolkit::Color qw/color/;
use Wx;
use App::GUI::Juliagraph::Widget::SliderStep;

my $default_sttings =  {
    color => 1, select => 8, repeat => 1, gradient => 10, dynamics => 0,
    use_bg_color => 1, grading => 1,
};

sub new {
    my ( $class, $parent, $config ) = @_;

    my $self = $class->SUPER::new( $parent, -1);
    $self->{'config'}     = $config;
    $self->{'callback'} = sub {};

    my $scale_lbl = Wx::StaticText->new($self, -1, 'S c a l e   D i v i s i o n : ' );


    my $color_lbl = Wx::StaticText->new($self, -1, 'C o l o r : ' );
    my $dyn_lbl  = Wx::StaticText->new($self, -1, 'D y n a m i c s : ' );
    my $bg_lbl  = Wx::StaticText->new($self, -1, 'B a c k g r o u n d : ' );
    $color_lbl->SetToolTip('use chosen color selection or just simple gray scale');
    $dyn_lbl->SetToolTip('how many big is the slant of a color gradient in one or another direction');

    $self->{'use_color'}     = Wx::CheckBox->new( $self, -1,  '', [-1,-1],[45, -1]);
    $self->{'background_color'} = Wx::ComboBox->new( $self, -1, 'black', [-1,-1],[110, -1], [qw/black white blue color_1 color_2 color_3 color_4 color_5 color_6 color_7 color_8 color_9 color_10 color_11/]);
    $self->{'bailout_color'} = Wx::ComboBox->new( $self, -1, 'black', [-1,-1],[110, -1], [qw/same black white blue color_1 color_2 color_3 color_4 color_5 color_6 color_7 color_8 color_9 color_10 color_11/]);
    $self->{'gradient_dynamics'}  = Wx::ComboBox->new( $self, -1,  0,  [-1,-1],[80, -1], [-10, -9, -8, -7, -6, -5, -4, -3, -2, -1.5, -1, -0.5, -0.2, 0, 0.2, 0.5, 1, 1.5, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]);
    $self->{'subgradient_dynamics'}  = Wx::ComboBox->new( $self, -1,  0,  [-1,-1],[80, -1], [-10, -9, -8, -7, -6, -5, -4, -3, -2, -1.5, -1, -0.5, -0.2, 0, 0.2, 0.5, 1, 1.5, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]);
    $self->{'use_color'}->SetToolTip('use chosen color selection (on) or just a gray scale');
    $self->{'background_color'}->SetToolTip('');
    $self->{'bailout_color'}->SetToolTip('');
    $self->{'gradient_dynamics'}->SetToolTip('');

    Wx::Event::EVT_CHECKBOX( $self, $self->{$_},            sub { $self->{'callback'}->() }) for qw/use_color/;
    Wx::Event::EVT_COMBOBOX( $self, $self->{$_},          sub { $self->{'callback'}->() }) for qw/gradient_dynamics background_color/;

    my $std_margin = 10;
    my $std  = &Wx::wxALIGN_LEFT | &Wx::wxALIGN_CENTER_VERTICAL | &Wx::wxGROW;
    my $box  = $std | &Wx::wxTOP | &Wx::wxBOTTOM;
    my $item = $std | &Wx::wxLEFT | &Wx::wxRIGHT;
    my $row  = $std | &Wx::wxTOP;

    my $color_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $color_sizer->Add( $color_lbl,          0, $box, 12);
    $color_sizer->AddSpacer( 10 );
    $color_sizer->Add( $self->{'use_color'},    0, $box,  0);
    $color_sizer->AddStretchSpacer();
    $color_sizer->AddSpacer( $std_margin );

    my $grad_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    # $grad_sizer->AddSpacer( $std_margin );
    $grad_sizer->AddSpacer( 10 );
    $grad_sizer->Add( $dyn_lbl,                        0, $box, 12);
    $grad_sizer->AddSpacer( 10 );
    $grad_sizer->Add( $self->{'gradient_dynamics'},    0, $box,  4);
    $grad_sizer->Add( $self->{'subgradient_dynamics'}, 0, $box,  4);
    $grad_sizer->AddStretchSpacer();
    $grad_sizer->AddSpacer( $std_margin );

    my $shades_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    # $shades_sizer->AddSpacer( $std_margin );
    $shades_sizer->AddSpacer( 52 );
    $shades_sizer->AddStretchSpacer();
    $shades_sizer->AddSpacer( $std_margin );

    my $bg_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $bg_sizer->AddSpacer( $std_margin );
    $bg_sizer->Add( $bg_lbl,                     0, $box,  12);
    $bg_sizer->AddSpacer( 10 );
    $bg_sizer->Add( $self->{'background_color'}, 0, $box,  12);
    $bg_sizer->AddSpacer( 10 );
    $bg_sizer->Add( $self->{'bailout_color'}, 0, $box,  12);
    $bg_sizer->AddSpacer( $std_margin );

    my $sizer_prop = &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxLEFT|&Wx::wxRIGHT;
    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
    $sizer->AddSpacer( $std_margin );
    $sizer->Add( $scale_lbl,        0, $item, $std_margin);
    $sizer->AddSpacer( 10 );
    $sizer->Add( $color_sizer,  0, $sizer_prop, $std_margin);
    $sizer->AddSpacer( 25 );
    $sizer->Add( $grad_sizer,   0, $sizer_prop, $std_margin);
    $sizer->AddSpacer( 25 );
    $sizer->Add( $shades_sizer, 0, $sizer_prop, $std_margin);
    $sizer->AddSpacer( 15 );
    $self->SetSizer($sizer);
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $box, 10 );
    $sizer->Add( $bg_sizer,     0, $sizer_prop, $std_margin);
    $sizer->AddSpacer( 10 );

    $self->init();
    $self;
}

sub init {
    my ( $self ) = @_;
    $self->set_settings ( );
}

sub get_settings {
    my ( $self ) = @_;
    {
        use_color  => int $self->{'use_color'}->GetValue,
        background_color  => $self->{'background_color'}->GetValue,
        bailout_color  => $self->{'bailout_color'}->GetValue,
        gradient_dynamics => $self->{'gradient_dynamics'}->GetStringSelection,
    }
}

sub set_settings {
    my ( $self, $data ) = @_;
    return 0 unless ref $data eq 'HASH' and exists $data->{'select'};
    $self->PauseCallBack();
    for my $key (qw/use_color/){
        next unless exists $data->{$key} and exists $self->{$key};
        $self->{$key}->SetValue( $data->{$key} );
    }
    for my $key (qw/background_color bailout_color gradient_dynamics/){
        next unless exists $data->{$key} and exists $self->{$key};
        $self->{$key}->SetSelection( $self->{$key}->FindString($data->{$key}) );
    }
    $self->RestoreCallBack();
    1;
}

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
