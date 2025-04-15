
# visible tab with all visual settings

package App::GUI::Juliagraph::Frame::Tab::Mapping;
use v5.12;
use warnings;
use base qw/Wx::Panel/;
use Graphics::Toolkit::Color qw/color/;
use Wx;
use App::GUI::Juliagraph::Widget::SliderStep;
use App::GUI::Juliagraph::Widget::SliderCombo;

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
    my $map_lbl = Wx::StaticText->new($self, -1, 'C o l o r   M a p p i n g : ' );
    my $submap_lbl = Wx::StaticText->new($self, -1, 'S u b   G r a d i e n t : ' );
    my $max_lbl = Wx::StaticText->new($self, -1, 'Max. : ' );
    my $distro_lbl = Wx::StaticText->new($self, -1, 'Distro : ' );
    my $color_lbl = Wx::StaticText->new($self, -1, 'Gray : ' );
    my $backg_lbl  = Wx::StaticText->new($self, -1, 'Background : ' );
    my $bail_lbl  = Wx::StaticText->new($self, -1, 'Bailout : ' );
    my $begin_lbl  = Wx::StaticText->new($self, -1, 'Rainbow Start : ' );
    my $end_lbl  = Wx::StaticText->new($self, -1, 'Rainbow End : ' );
    my $map_dyn_lbl = Wx::StaticText->new($self, -1, 'Dynamics : ' );
    my $map_space_lbl = Wx::StaticText->new($self, -1, 'Space : ' );
    my $use_sub_lbl  = Wx::StaticText->new($self, -1, 'On : ' );
    my $sub_step_lbl  = Wx::StaticText->new($self, -1, 'Steps : ' );
    my $sub_dyn_lbl = Wx::StaticText->new($self, -1, 'Dyn. : ' );
    my $sub_space_lbl = Wx::StaticText->new($self, -1, 'Space : ' );
    $scale_lbl->SetToolTip('divide the possible iteration counts into goups that can be mapped to colors');
    $map_lbl->SetToolTip('decide to which colors the iteration counts get mapped');
    $submap_lbl->SetToolTip('');
    $color_lbl->SetToolTip('use chosen color selection or just simple gray scale');
    $map_dyn_lbl->SetToolTip('how many big is the slant of a color gradient in one or another direction');
    $sub_dyn_lbl->SetToolTip('how many big is the slant of a color gradient in one or another direction');
    $map_space_lbl->SetToolTip('');
    $sub_space_lbl->SetToolTip('');

    my @color_names = ('color 1','color 2','color 3','color 4', 'color 5', 'color 6','color 7','color 8','color 9', 'color 10', 'color 11');

    $self->{'use_color'}     = Wx::CheckBox->new( $self, -1,  '', [-1,-1],[45, -1]);
    $self->{'use_subdivision'} = Wx::CheckBox->new( $self, -1,  '', [-1,-1],[30, -1]);
    $self->{'div_parts'} = App::GUI::Juliagraph::Widget::SliderCombo->new( $self, 140, 'Partitions:', "", 2, 100, 20);
    $self->{'div_min'} = App::GUI::Juliagraph::Widget::SliderCombo->new( $self, 140, 'Minimum:', "", 0, 100, 0);
    $self->{'div_max'} = Wx::TextCtrl->new( $self, -1, 0, [-1,-1], [70,-1], &Wx::wxTE_RIGHT | &Wx::wxTE_READONLY);
    $self->{'div_distro'} = Wx::ComboBox->new( $self, -1, 'linear', [-1,-1],[100, -1], [qw/linear square cube sqrt cubert log exp/]);
    $self->{'start_color'} = Wx::ComboBox->new( $self, -1, 'color 3', [-1,-1],[110, -1], [@color_names]);
    $self->{'stop_color'} = Wx::ComboBox->new( $self, -1, 'color 4', [-1,-1],[110, -1], [@color_names]);
    $self->{'background_color'} = Wx::ComboBox->new( $self, -1, 'black', [-1,-1],[110, -1], [qw/black white blue/, @color_names]);
    $self->{'bailout_color'} = Wx::ComboBox->new( $self, -1, 'black', [-1,-1],[110, -1], [qw/same black white blue/, @color_names]);
    $self->{'gradient_dynamics'}  = Wx::ComboBox->new( $self, -1,  0,  [-1,-1],[80, -1], [-10, -9, -8, -7, -6, -5, -4, -3, -2, -1.5, -1, -0.5, -0.2, 0, 0.2, 0.5, 1, 1.5, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]);
    $self->{'gradient_space'}  = Wx::ComboBox->new( $self, -1,  'RGB',  [-1,-1],[80, -1], [qw/RGB HSL/]);
    $self->{'subgradient_steps'}  = Wx::ComboBox->new( $self, -1,  '10',  [-1,-1],[80, -1], [qw/5 10 15 20 25 30 35/]);
    $self->{'subgradient_space'}  = Wx::ComboBox->new( $self, -1,  'RGB',  [-1,-1],[80, -1], [qw/RGB HSL/]);
    $self->{'subgradient_dynamics'}  = Wx::ComboBox->new( $self, -1,  0,  [-1,-1],[80, -1], [-10, -9, -8, -7, -6, -5, -4, -3, -2, -1.5, -1, -0.5, -0.2, 0, 0.2, 0.5, 1, 1.5, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]);
    $self->{'use_color'}->SetToolTip('use chosen color selection (on) or just a gray scale');
    $self->{'background_color'}->SetToolTip('');
    $self->{'bailout_color'}->SetToolTip('');
    $self->{'gradient_dynamics'}->SetToolTip('');

    Wx::Event::EVT_CHECKBOX( $self, $self->{$_},            sub { $self->{'callback'}->() }) for qw/use_color/;
    Wx::Event::EVT_COMBOBOX( $self, $self->{$_},          sub { $self->{'callback'}->() }) for qw/gradient_dynamics background_color/;

    my $std_margin = 20;
    my $std  = &Wx::wxALIGN_LEFT | &Wx::wxALIGN_CENTER_VERTICAL | &Wx::wxGROW;
    my $box  = $std | &Wx::wxTOP | &Wx::wxBOTTOM;
    my $item = $std | &Wx::wxLEFT;
    my $row  = $std | &Wx::wxTOP;

    my $div_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $div_sizer->AddSpacer( $std_margin );
    $div_sizer->AddSpacer( 10 );
    $div_sizer->Add( $self->{'div_parts'},   0, $box,  5);
    $div_sizer->AddSpacer( 40 );
    $div_sizer->Add( $distro_lbl,            0, $box, 12);
    $div_sizer->AddSpacer( 10 );
    $div_sizer->Add( $self->{'div_distro'},  0, $box,  5);
    $div_sizer->AddStretchSpacer();
    $div_sizer->AddSpacer( $std_margin );

    my $div2_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $div2_sizer->AddSpacer( $std_margin );
    $div2_sizer->AddSpacer( 10 );
    $div2_sizer->Add( $self->{'div_min'},  0, $box,  5);
    $div2_sizer->AddSpacer( 50 );
    $div2_sizer->Add( $max_lbl,        0, $box, 12);
    $div2_sizer->AddSpacer( 10 );
    $div2_sizer->Add( $self->{'div_max'},  0, $box,  5);
    $div2_sizer->AddStretchSpacer();
    $div2_sizer->AddSpacer( $std_margin );

    my $color_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $color_sizer->AddSpacer( $std_margin );
    $color_sizer->AddSpacer( 10 );
    $color_sizer->Add( $color_lbl,              0, $box, 12);
    $color_sizer->AddSpacer( 10 );
    $color_sizer->Add( $self->{'use_color'},    0, $box,  0);
    $color_sizer->AddSpacer( 10 );
    $color_sizer->Add( $backg_lbl,               0, $box, 12);
    $color_sizer->AddSpacer( 10 );
    $color_sizer->Add( $self->{'background_color'}, 0, $box,  5);
    $color_sizer->AddSpacer( 38 );
    $color_sizer->Add( $bail_lbl,               0, $box, 12);
    $color_sizer->AddSpacer( 10 );
    $color_sizer->Add( $self->{'bailout_color'},    0, $box,  5);
    $color_sizer->AddStretchSpacer();
    $color_sizer->AddSpacer( $std_margin );

    my $map_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $map_sizer->AddSpacer( $std_margin );
    $map_sizer->AddSpacer( 70 );
    $map_sizer->Add( $begin_lbl,              0, $box, 12);
    $map_sizer->AddSpacer( 10 );
    $map_sizer->Add( $self->{'start_color'},  0, $box,  5);
    $map_sizer->AddSpacer( 36 );
    $map_sizer->Add( $end_lbl,                0, $box, 12);
    $map_sizer->AddSpacer( 10 );
    $map_sizer->Add( $self->{'stop_color'},   0, $box,  5);
    $map_sizer->AddSpacer( 10 );
    $map_sizer->Add( $map_space_lbl,          0, $box, 12);
    $map_sizer->AddStretchSpacer();
    $map_sizer->AddSpacer( $std_margin );

    my $map2_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $map2_sizer->AddSpacer( $std_margin );
    $map2_sizer->AddSpacer( 90 );
    $map2_sizer->Add( $map_dyn_lbl,            0, $box, 12);
    $map2_sizer->AddSpacer( 10 );
    $map2_sizer->Add( $self->{'gradient_dynamics'}, 0, $box,  5);
    $map2_sizer->AddSpacer( 116 );
    $map2_sizer->Add( $map_space_lbl,          0, $box, 12);
    $map2_sizer->AddSpacer( 10 );
    $map2_sizer->Add( $self->{'gradient_space'}, 0, $box,  5);
    $map2_sizer->AddStretchSpacer();
    $map2_sizer->AddSpacer( $std_margin );

    my $sub_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $sub_sizer->AddSpacer( $std_margin );
    $sub_sizer->AddSpacer( 10 );
    $sub_sizer->Add( $use_sub_lbl,               0, $box, 12);
    $sub_sizer->AddSpacer( 10 );
    $sub_sizer->Add( $self->{'use_subdivision'}, 0, $box,  4);
    $sub_sizer->AddSpacer( 10 );
    $sub_sizer->Add( $sub_step_lbl,              0, $box, 12);
    $sub_sizer->AddSpacer( 10 );
    $sub_sizer->Add( $self->{'subgradient_steps'},  0, $box,  4);
    $sub_sizer->AddSpacer( 20 );
    $sub_sizer->Add( $sub_dyn_lbl,               0, $box, 12);
    $sub_sizer->AddSpacer( 10 );
    $sub_sizer->Add( $self->{'subgradient_dynamics'}, 0, $box,  4);
    $sub_sizer->AddSpacer( 20 );
    $sub_sizer->Add( $sub_space_lbl,             0, $box, 12);
    $sub_sizer->AddSpacer( 10 );
    $sub_sizer->Add( $self->{'subgradient_space'},  0, $box,  4);
    $sub_sizer->AddStretchSpacer();
    $sub_sizer->AddSpacer( $std_margin );

    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
    $sizer->AddSpacer( 10 );
    $sizer->Add( $scale_lbl,    0, $item,  $std_margin);
    $sizer->Add( $div_sizer,    0, $row,   8);
    $sizer->Add( $div2_sizer,   0, $row,  10);
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $box, 10 );
    $sizer->Add( $map_lbl,      0, $item,  $std_margin);
    $sizer->Add( $color_sizer,  0, $row,   8);
    $sizer->Add( $map_sizer,    0, $row,  10);
    $sizer->Add( $map2_sizer,   0, $row,  10);
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $box, 10 );
    $sizer->Add( $submap_lbl,   0, $item, $std_margin);
    $sizer->Add( $sub_sizer,    0, $row,   8);
    $sizer->AddSpacer( 2 );
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $box, 10 );
    $sizer->AddStretchSpacer();
    $self->SetSizer($sizer);

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
