use v5.12;
use warnings;
use Wx;

package App::GUI::Juliagraph::Frame::Panel::Mapping;
use base qw/Wx::Panel/;
use App::GUI::Juliagraph::Widget::SliderStep;

sub new {
    my ( $class, $parent) = @_;
    my $self = $class->SUPER::new( $parent, -1);

    my $shade_lbl  = Wx::StaticText->new($self, -1, 'S h a d e s : ' );
    my $scale_lbl  = Wx::StaticText->new($self, -1, 'S c a l i n g : ' );
    my $smooth_lbl = Wx::StaticText->new($self, -1, 'S m o o t h : ' );

    #$self->{'const_a'}  = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    #$self->{'button_a'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, '<<', '>>' );
    $self->{'smooth'} = Wx::CheckBox->new( $self, -1, '', [-1,-1],[45, -1]);
    $self->{'shades'} = Wx::ComboBox->new( $self, -1, 256, [-1,-1],[95, -1], [8, 16, 24, 32, 40, 64, 80, 128, 160, 210, 256, 512]);
    $self->{'scaling'} = Wx::ComboBox->new( $self, -1, 25, [-1,-1],[95, -1], [1, 2, 3, 5, 8, 10, 13, 17, 20, 25, 30, 35, 40, 45]);

    #$self->{'button_a'}->SetCallBack(sub { $self->{'const_a'}->SetValue( $self->{'const_a'}->GetValue + shift ) });

    Wx::Event::EVT_CHECKBOX( $self, $self->{'smooth'}, sub { $self->{'callback'}->() });
    Wx::Event::EVT_TEXT( $self, $self->{$_},           sub { $self->{'callback'}->() }) for qw//;
    Wx::Event::EVT_COMBOBOX( $self, $self->{$_},       sub { $self->{'callback'}->() }) for qw/shades scaling/;

    my $vert_prop = &Wx::wxALIGN_LEFT|&Wx::wxTOP|&Wx::wxBOTTOM|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxALIGN_CENTER_HORIZONTAL|&Wx::wxGROW;
    my $item_prop = &Wx::wxALIGN_LEFT|&Wx::wxLEFT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxALIGN_CENTER_HORIZONTAL|&Wx::wxGROW;
    my $txt_prop  = &Wx::wxALIGN_LEFT|&Wx::wxLEFT|&Wx::wxRIGHT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxGROW;
    my $sizer_prop = &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxLEFT|&Wx::wxRIGHT;
    my $std_margin = 10;

    my $smooth_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $smooth_sizer->Add( $smooth_lbl,  0, $vert_prop, 12);
    $smooth_sizer->AddSpacer( 10 );
    $smooth_sizer->Add( $self->{'smooth'},  0, $vert_prop, 4);
    $smooth_sizer->Add( 0, 0, &Wx::wxEXPAND | &Wx::wxGROW);
    $smooth_sizer->AddSpacer( $std_margin );

    my $grain_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $grain_sizer->Add( $shade_lbl,  0, $item_prop, 0);
    $grain_sizer->AddSpacer( 10 );
    $grain_sizer->Add( $self->{'shades'},  0, $vert_prop, 0);
    $grain_sizer->Add( 0, 0, &Wx::wxEXPAND | &Wx::wxGROW);
    $grain_sizer->Add( $scale_lbl,  0, $item_prop, 0);
    $grain_sizer->AddSpacer( 10 );
    $grain_sizer->Add( $self->{'scaling'},  0, $vert_prop, 0);
    $grain_sizer->AddSpacer( $std_margin );

    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
    $sizer->Add( $smooth_sizer,  0, $sizer_prop, $std_margin);
    $sizer->AddSpacer( 20 );
    $sizer->Add( $grain_sizer,  0, $sizer_prop, $std_margin);
    $sizer->AddSpacer( 30 );
    $self->SetSizer($sizer);

    $self->{'callback'} = sub {};
    $self->init();
    $self;
}

sub init {
    my ( $self ) = @_;
    $self->set_data ({ shades => 256, scaling => 20, smooth => 0} );
}

sub get_data {
    my ( $self ) = @_;
    {
        smooth  => int $self->{'smooth'}->GetValue,
        shades  => $self->{'shades'}->GetStringSelection,
        scaling => $self->{'scaling'}->GetStringSelection,
    }
}

sub set_data {
    my ( $self, $data ) = @_;
    return 0 unless ref $data eq 'HASH' and exists $data->{'shades'};
    $self->PauseCallBack();
    for my $key (qw/smooth/){
        next unless exists $data->{$key} and exists $self->{$key};
        $self->{$key}->SetValue( $data->{$key} );
    }
    for my $key (qw/shades scaling/){
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
