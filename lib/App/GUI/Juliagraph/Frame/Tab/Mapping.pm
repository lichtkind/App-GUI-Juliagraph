
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
    my $sel_lbl  = Wx::StaticText->new($self, -1, 'S e l e c t : ' );
    my $repeat_lbl = Wx::StaticText->new($self, -1, 'R e p e a t : ' );
    my $group_lbl  = Wx::StaticText->new($self, -1, 'A m o u n t : ' );
    my $grad_lbl  = Wx::StaticText->new($self, -1, 'G r a d i e n t : ' );
    my $dyn_lbl  = Wx::StaticText->new($self, -1, 'D y n a m i c s : ' );
    my $bg_lbl  = Wx::StaticText->new($self, -1, 'B a c k g r o u n d : ' );
    $color_lbl->SetToolTip('use chosen color selection or just simple gray scale');
    $sel_lbl->SetToolTip('tonly use the first n selected colors');
    $repeat_lbl->SetToolTip('how many times repeat the configured color rainbow');
    $group_lbl->SetToolTip('how many neighbouring stop values are being translated into one color');
    $grad_lbl->SetToolTip('how many shades has a gradient between two selected colors');
    $dyn_lbl->SetToolTip('how many big is the slant of a color gradient in one or another direction');

    $self->{'color'}     = Wx::CheckBox->new( $self, -1,  '', [-1,-1],[45, -1]);
    $self->{'use_bg_color'} = Wx::CheckBox->new( $self, -1,  '', [-1,-1],[45, -1]);
    $self->{'select'}    = Wx::ComboBox->new( $self, -1,   8, [-1,-1],[65, -1], [2 .. 8]);
    $self->{'repeat'}    = Wx::ComboBox->new( $self, -1, 256, [-1,-1],[65, -1], [1 .. 20]);
    $self->{'grading'}   = Wx::ComboBox->new( $self, -1,  1,  [-1,-1],[75, -1], [1 .. 16]);
    $self->{'gradient'}  = Wx::ComboBox->new( $self, -1, 25,  [-1,-1],[80, -1], [0, 1,  2,  3,  4, 5, 6, 7, 8, 10, 12, 15, 20, 25, 30, 35, 40, 50, 65, 80, 100]);
    $self->{'dynamics'}  = Wx::ComboBox->new( $self, -1,  0,  [-1,-1],[80, -1], [-10, -9, -8, -7, -6, -5, -4, -3, -2, -1.5, -1, -0.5, -0.2, 0, 0.2, 0.5, 1, 1.5, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]);

    $self->{'color'}->SetToolTip('use chosen color selection or just simple gray scale');
    $self->{'use_bg_color'}->SetToolTip('use chosen background color or just black');
    $self->{'repeat'}->SetToolTip('take first color again when ran out of colors');
    $self->{'select'}->SetToolTip('the first n stop values are translated into colors');
    $self->{'grading'}->SetToolTip('how many neighbouring stop values are being translated into one color or how many additional colors are introduced by subgradient');
    $self->{'gradient'}->SetToolTip('how many shades has a gradient between two selected colors');
    $self->{'dynamics'}->SetToolTip('how many big is the slant of a color gradient in one or another direction');

    Wx::Event::EVT_CHECKBOX( $self, $self->{$_},            sub { $self->{'callback'}->() }) for qw/color use_bg_color/;
    Wx::Event::EVT_COMBOBOX( $self, $self->{$_},          sub { $self->{'callback'}->() }) for qw/select repeat grading gradient dynamics/;
    Wx::Event::EVT_COMBOBOX( $self, $self->{'select'},  sub { $self->{'callback'}->(); $self->GetParent->GetParent->{'tab'}{'color'}->set_state_count( $self->{'select'}->GetStringSelection - 1 ) });

    my $std_margin = 10;
    my $std  = &Wx::wxALIGN_LEFT | &Wx::wxALIGN_CENTER_VERTICAL | &Wx::wxGROW;
    my $box  = $std | &Wx::wxTOP | &Wx::wxBOTTOM;
    my $item = $std | &Wx::wxLEFT | &Wx::wxRIGHT;
    my $row  = $std | &Wx::wxTOP;

    my $color_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $color_sizer->Add( $color_lbl,          0, $box, 12);
    $color_sizer->AddSpacer( 10 );
    $color_sizer->Add( $self->{'color'},    0, $box,  0);
    $color_sizer->AddStretchSpacer();
    $color_sizer->Add( $sel_lbl,            0, $box, 12);
    $color_sizer->AddSpacer( 10 );
    $color_sizer->Add( $self->{'select'},   0, $box,  4);
    $color_sizer->AddSpacer( 25 );
    $color_sizer->Add( $repeat_lbl,         0, $box, 12);
    $color_sizer->AddSpacer( 10 );
    $color_sizer->Add( $self->{'repeat'},   0, $box,  4);
    $color_sizer->AddSpacer( $std_margin );

    my $grad_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    # $grad_sizer->AddSpacer( $std_margin );
    $grad_sizer->Add( $grad_lbl,            0, $box, 12);
    $grad_sizer->AddSpacer( 10 );
    $grad_sizer->Add( $self->{'gradient'},  0, $box,  4);
    $grad_sizer->AddSpacer( 25 );
    $grad_sizer->Add( $dyn_lbl,             0, $box, 12);
    $grad_sizer->AddSpacer( 10 );
    $grad_sizer->Add( $self->{'dynamics'},  0, $box,  4);
    $grad_sizer->AddStretchSpacer();
    $grad_sizer->AddSpacer( $std_margin );

    my $shades_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    # $shades_sizer->AddSpacer( $std_margin );
    $shades_sizer->AddSpacer( 52 );
    $shades_sizer->Add( $group_lbl,              0, $box,  16);
    $shades_sizer->AddSpacer( 10 );
    $shades_sizer->Add( $self->{'grading'},      0, $box,   8);
    $shades_sizer->AddStretchSpacer();
    $shades_sizer->AddSpacer( $std_margin );

    my $bg_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $bg_sizer->AddSpacer( $std_margin );
    $bg_sizer->Add( $bg_lbl,                     0, $box,  12);
    $bg_sizer->AddSpacer( 10 );
    $bg_sizer->Add( $self->{'use_bg_color'},     0, $box,   0);
    $bg_sizer->AddSpacer( 10 );
    $bg_sizer->Add( $self->{'background_color'}, 0, $box,  12);
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
        color   => int $self->{'color'}->GetValue,
        use_bg_color  => int $self->{'use_bg_color'}->GetValue,
        repeat  => $self->{'repeat'}->GetStringSelection,
        select  => $self->{'select'}->GetStringSelection,
        grading => $self->{'grading'}->GetStringSelection,
        gradient => $self->{'gradient'}->GetStringSelection,
        dynamics => $self->{'dynamics'}->GetStringSelection,
    }
}

sub set_settings {
    my ( $self, $data ) = @_;
    return 0 unless ref $data eq 'HASH' and exists $data->{'select'};
    $self->PauseCallBack();
    for my $key (qw/color use_bg_color/){
        next unless exists $data->{$key} and exists $self->{$key};
        $self->{$key}->SetValue( $data->{$key} );
    }
    for my $key (qw/select repeat grading gradient dynamics/){
        next unless exists $data->{$key} and exists $self->{$key};
        $self->{$key}->SetSelection( $self->{$key}->FindString($data->{$key}) );
    }
    $self->set_current_color( color( $data->{'background_color'} )->values( as => 'hash' ) )
        if exists $data->{'background_color'};
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
