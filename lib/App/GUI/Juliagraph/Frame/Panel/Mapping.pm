use v5.12;
use warnings;
use Wx;

package App::GUI::Juliagraph::Frame::Panel::Mapping;
use base qw/Wx::Panel/;
use App::GUI::Juliagraph::Widget::SliderStep;

sub new {
    my ( $class, $parent) = @_;
    my $self = $class->SUPER::new( $parent, -1);

    my $color_lbl = Wx::StaticText->new($self, -1, 'C o l o r : ' );
    my $repeat_lbl = Wx::StaticText->new($self, -1, 'R e p e a t : ' );
    my $shade_lbl  = Wx::StaticText->new($self, -1, 'S h a d e s : ' );
    my $group_lbl  = Wx::StaticText->new($self, -1, 'G r o u p i n g : ' );
    my $grad_lbl  = Wx::StaticText->new($self, -1, 'G r a d i e n t : ' );
    # my $smooth_lbl = Wx::StaticText->new($self, -1, 'S m o o t h : ' );
    $color_lbl->SetToolTip('use chosen color selection or just simple gray scale');
    $repeat_lbl->SetToolTip('take first color again when ran out of colors');
    $shade_lbl->SetToolTip('the first n stop values are translated into colors');
    $group_lbl->SetToolTip('how many neighbouring stop values are being translated into one color');

    $self->{'color'} = Wx::CheckBox->new( $self, -1, '', [-1,-1],[45, -1]);
    $self->{'repeat'} = Wx::CheckBox->new( $self, -1, '', [-1,-1],[45, -1]);
    #$self->{'smooth'} = Wx::CheckBox->new( $self, -1, '', [-1,-1],[45, -1]);
    $self->{'shades'}   = Wx::ComboBox->new( $self, -1, 256, [-1,-1],[95, -1], [8, 16, 24, 32, 40, 64, 80, 128, 160, 210, 256, 512, 1024]);
    $self->{'grouping'} = Wx::ComboBox->new( $self, -1, 25,  [-1,-1],[75, -1], [1,  2,  3,  5, 8, 10, 13, 17, 20, 25, 30, 35, 40, 45, 50, 60, 70, 85]);
    $self->{'gradient'} = Wx::ComboBox->new( $self, -1, 25,  [-1,-1],[75, -1], [1,  2,  3,  4, 5, 6, 7, 8, 10, 12, 15, 20, 25, 30, 35, 40]);
    #$self->{'substeps'} = Wx::ComboBox->new( $self, -1, 25,  [-1,-1],[75, -1], [1,  2,  3,  4, 5, 6, 7, 8, 10, 12, 15, 20, 25, 30, 35, 40]);
    $self->{'color'}->SetToolTip('use chosen color selection or just simple gray scale');
    $self->{'repeat'}->SetToolTip('take first color again when ran out of colors');
    $self->{'shades'}->SetToolTip('the first n stop values are translated into colors');
    $self->{'grouping'}->SetToolTip('how many neighbouring stop values are being translated into one color');
    #$self->{'substeps'}->SetToolTip('');

    Wx::Event::EVT_CHECKBOX( $self, $self->{$_},  sub { $self->{'callback'}->() }) for qw/color/;
    Wx::Event::EVT_COMBOBOX( $self, $self->{$_},  sub { $self->{'callback'}->() }) for qw/shades grouping gradient/;
    Wx::Event::EVT_TEXT(     $self, $self->{$_},  sub { $self->{'callback'}->() }) for qw//;

    my $vert_prop = &Wx::wxALIGN_LEFT|&Wx::wxTOP|&Wx::wxBOTTOM|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxALIGN_CENTER_HORIZONTAL|&Wx::wxGROW;
    my $item_prop = &Wx::wxALIGN_LEFT|&Wx::wxLEFT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxALIGN_CENTER_HORIZONTAL|&Wx::wxGROW;
    my $txt_prop  = &Wx::wxALIGN_LEFT|&Wx::wxLEFT|&Wx::wxRIGHT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxGROW;
    my $sizer_prop = &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxLEFT|&Wx::wxRIGHT;
    my $std_margin = 10;

    my $color_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $color_sizer->Add( $color_lbl,  0, $vert_prop, 12);
    $color_sizer->AddSpacer( 10 );
    $color_sizer->Add( $self->{'color'},  0, $vert_prop, 4);
    $color_sizer->AddSpacer( 20 );
    $color_sizer->Add( $repeat_lbl,  0, $vert_prop, 12);
    $color_sizer->AddSpacer( 10 );
    $color_sizer->Add( $self->{'repeat'},  0, $vert_prop, 4);
    $color_sizer->Add( 0, 0, &Wx::wxEXPAND | &Wx::wxGROW);
    $color_sizer->AddSpacer( $std_margin );

    my $smooth_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    #~ $smooth_sizer->Add( $smooth_lbl,  0, $vert_prop, 12);
    #~ $smooth_sizer->AddSpacer( 10 );
    #~ $smooth_sizer->Add( $self->{'smooth'},  0, $vert_prop, 4);
    #~ $smooth_sizer->Add( 0, 0, &Wx::wxEXPAND | &Wx::wxGROW);
    #~ $smooth_sizer->AddSpacer( $std_margin );

    my $shades_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $shades_sizer->Add( $shade_lbl,  0, $vert_prop, 12);
    $shades_sizer->AddSpacer( 10 );
    $shades_sizer->Add( $self->{'shades'},  0, $vert_prop, 0);
    $shades_sizer->Add( 0, 0, &Wx::wxEXPAND | &Wx::wxGROW);
    $shades_sizer->Add( $group_lbl,  0, $vert_prop, 12);
    $shades_sizer->AddSpacer( 10 );
    $shades_sizer->Add( $self->{'grouping'},  0, $vert_prop, 0);
    $shades_sizer->AddSpacer( $std_margin );

    my $grad_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $grad_sizer->Add( $grad_lbl,  0, $vert_prop, 12);
    $grad_sizer->AddSpacer( 10 );
    $grad_sizer->Add( $self->{'gradient'},  0, $vert_prop, 0);
    $grad_sizer->Add( 0, 0, &Wx::wxEXPAND | &Wx::wxGROW);
    $grad_sizer->AddSpacer( $std_margin );

    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
    $sizer->AddSpacer( $std_margin );
    $sizer->Add( $color_sizer,  0, $sizer_prop, $std_margin);
    $sizer->Add( $smooth_sizer,  0, $sizer_prop, $std_margin);
    $sizer->AddSpacer( 20 );
    $sizer->Add( $shades_sizer,  0, $sizer_prop, $std_margin);
    $sizer->AddSpacer( 35 );
    $sizer->Add( $grad_sizer,  0, $sizer_prop, $std_margin);
    $sizer->AddSpacer( 30 );
    $self->SetSizer($sizer);

    $self->{'callback'} = sub {};
    $self->init();
    $self;
}

sub init {
    my ( $self ) = @_;
    $self->set_data ({ color => 1, repeat => 1,
                       shades => 256, grouping => 1, gradient => 8, smooth => 0, substeps => 0 } );
}

sub get_data {
    my ( $self ) = @_;
    {
        color   => int $self->{'color'}->GetValue,
        repeat  => int $self->{'repeat'}->GetValue,
        shades  => $self->{'shades'}->GetStringSelection,
        gradient => $self->{'gradient'}->GetStringSelection,
        grouping => $self->{'grouping'}->GetStringSelection,
        # smooth  => int $self->{'smooth'}->GetValue,
        # substeps => $self->{'substeps'}->GetStringSelection,
    }
}

sub set_data {
    my ( $self, $data ) = @_;
    return 0 unless ref $data eq 'HASH' and exists $data->{'shades'};
    $self->PauseCallBack();
    for my $key (qw/color repeat/){ # smooth
        next unless exists $data->{$key} and exists $self->{$key};
        $self->{$key}->SetValue( $data->{$key} );
    }
    for my $key (qw/shades grouping gradient/){# substeps
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
