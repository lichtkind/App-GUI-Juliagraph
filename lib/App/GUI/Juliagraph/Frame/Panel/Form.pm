use v5.12;
use warnings;
use Wx;

package App::GUI::Juliagraph::Frame::Panel::Form;
use base qw/Wx::Panel/;
use App::GUI::Juliagraph::Widget::SliderCombo;

sub new {
    my ( $class, $parent) = @_;
    my $self = $class->SUPER::new( $parent, -1);

    $self->{'callback'} = sub {};

    $self->{'type'} = Wx::RadioBox->new( $self, -1, ' T y p e ', [-1,-1],[-1,-1], ['Julia','Mandelbrot'] );

    my $const_lbl  = Wx::StaticText->new($self, -1, 'C o n s t a n t :' );
    my $exp_lbl  = Wx::StaticText->new($self, -1, 'E x p :' );
    my $pos_lbl  = Wx::StaticText->new($self, -1, 'P o s i t i o n : ' );
    my $zoom_lbl  = Wx::StaticText->new($self, -1, 'Z o o m : ' );
    my $stop_lbl  = Wx::StaticText->new($self, -1, 'S t o p : ' );

    $self->{'const'}   = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [80, -1] );
    $self->{'const_i'} = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [80, -1] );
    $self->{'pos_x'} = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [120, -1] );
    $self->{'pos_y'} = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [120, -1] );
    $self->{'zoom'} = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [80, -1] );
    $self->{'exp'} = Wx::ComboBox->new( $self, -1, 2, [-1,-1],[65, -1], [2,3,4,5,6,7,8,9,10,11,12]);
    $self->{'exp'}->SetToolTip('exponent of iterator variable');
    $self->{'stop'} = Wx::ComboBox->new( $self, -1, 1000, [-1,-1],[85, -1], [50,100, 400, 1000, 3000, 10000]);


    #$self->{'on'} = Wx::CheckBox->new( $self, -1, '', [-1,-1],[-1,-1], 1 );
    #~ $self->{'frequency'}  = App::GUI::Juliagraph::SliderCombo->new( $self, 100, 'f', 'frequency of '.$help, 1, $max, 1 );



    #~ Wx::Event::EVT_RADIOBOX( $self, $self->{'on'},          sub { $self->update_enable(); $self->{'callback'}->() });
    #~ Wx::Event::EVT_TEXT( $self, $self->{'invert_freq'}, sub {                         $self->{'callback'}->() });
    #~ Wx::Event::EVT_CHECKBOX( $self, $self->{'direction'},   sub {                         $self->{'callback'}->() });

    my $item_prop = &Wx::wxALIGN_LEFT|&Wx::wxLEFT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxGROW;
    my $f_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $f_sizer->Add( $const_lbl, 1, $item_prop, 0);
    $f_sizer->Add( $self->{'const'}, 1, $item_prop, 30);
    $f_sizer->Add( $self->{'const_i'}, 1, $item_prop, 10);
    $f_sizer->Add( $exp_lbl, 1, $item_prop, 40);
    $f_sizer->Add( $self->{'exp'}, 1, $item_prop, 20);
    $f_sizer->Add( 0, 0, &Wx::wxEXPAND | &Wx::wxGROW);

    #~ my $r_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    #~ my $r_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    #~ $r_sizer->Add( $self->{'on'},       0, &Wx::wxALIGN_LEFT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxGROW|&Wx::wxLEFT, 0);
    #~ $r_sizer->Add( $lbl,                0, &Wx::wxALIGN_LEFT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxGROW|&Wx::wxALL, 12);
    #~ $r_sizer->Add( $self->{'radius'},   0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxLEFT,  0);
    #~ $r_sizer->Add( $self->{'damp'},     0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxLEFT,  0);
    #~ $r_sizer->Add( 0, 0, &Wx::wxEXPAND | &Wx::wxGROW);

    #~ my $o_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    #~ $o_sizer->Add( $self->{'invert_freq'}, 0, &Wx::wxALIGN_LEFT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxGROW|&Wx::wxLEFT, 86);
    #~ $o_sizer->Add( $self->{'direction'},   0, &Wx::wxALIGN_LEFT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxGROW|&Wx::wxLEFT, 20);
    #~ $o_sizer->Add( $self->{'half_off'},    0, &Wx::wxALIGN_LEFT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxGROW|&Wx::wxLEFT, 20);
    #~ $o_sizer->Add( $self->{'quarter_off'}, 0, &Wx::wxALIGN_LEFT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxGROW|&Wx::wxLEFT,  8);
    #~ $o_sizer->Add( $self->{'offset'},      0, &Wx::wxALIGN_LEFT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxGROW|&Wx::wxLEFT,  0);
    #~ $o_sizer->Add( 0, 0, &Wx::wxEXPAND | &Wx::wxGROW);

    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
    $sizer->Add( $self->{'type'},  0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, 10);
    $sizer->AddSpacer( 15 );
    $sizer->Add( $f_sizer,  0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, 10);
    $sizer->Add( $pos_lbl,  0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, 10);
    $sizer->Add( $self->{'pos_x'},  0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, 10);
    $sizer->Add( $self->{'pos_y'},  0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, 10);
    $sizer->Add( $zoom_lbl,  0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, 10);
    $sizer->Add( $self->{'zoom'},  0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, 10);
    $sizer->Add( $stop_lbl,  0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, 10);
    $sizer->Add( $self->{'stop'},  0, &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL, 10);
    $self->SetSizer($sizer);

    #$self->init();
    $self;
}

sub init {
    my ( $self ) = @_;
    # $self->set_data ({ on => $self->{'initially_on'}, radius => 1, frequency => 1, offset => 0, damp => 0} );
}

sub get_data {
    my ( $self ) = @_;
    {
        #~ on        => $self->{ 'on' }->IsChecked ? 1 : 0,
        #~ frequency => $f,
        #~ offset    => (0.5 * $self->{'half_off'}->IsChecked)
                   #~ + (0.25 * $self->{'quarter_off'}->IsChecked)
                   #~ + ($self->{'offset'}->GetValue / 400),
        #~ radius    => $self->{'radius'}->GetValue / 100,
        #~ damp      => $self->{'damp'}->GetValue,
    }
}

sub SetCallBack {
    my ( $self, $code) = @_;
    return unless ref $code eq 'CODE';
    $self->{'callback'} = $code;
#    $self->{ $_ }->SetCallBack( $code ) for qw /radius damp frequency freq_dez offset/;
}


sub set_data {
    my ( $self, $data ) = @_;
    #~ return unless ref $data eq 'HASH' and exists $data->{'frequency'}
        #~ and exists $data->{'offset'} and exists $data->{'radius'} and exists $data->{'damp'};
    #~ $self->{ 'data'} = $data;
    #~ $self->{ 'on' }->SetValue( $data->{'on'} );
    #~ $self->{ 'direction' }->SetValue( $data->{'frequency'} < 0 );
    #~ $data->{ 'frequency'} = abs $data->{'frequency'};
    #~ $self->{ 'invert_freq' }->SetValue( $data->{'frequency'} < 1 );
    #~ $data->{ 'frequency'} = 1 / $data->{'frequency'} if $data->{'frequency'} < 1;
    #~ $self->{ 'frequency' }->SetValue( int $data->{'frequency'}, 1 );
    #~ $self->{ 'freq_dez' }->SetValue( int( 1000 * ($data->{'frequency'} - int $data->{'frequency'} ) ), 1 );
    #~ $self->{ 'half_off' }->SetValue( $data->{'offset'} >= 0.5 );
    #~ $data->{ 'offset' } -= 0.5 if $data->{'offset'} >= 0.5;
    #~ $self->{ 'quarter_off' }->SetValue( $data->{'offset'} >= 0.25 );
    #~ $data->{ 'offset' } -= 0.25 if $data->{'offset'} >= 0.25;
    #~ $self->{'offset'}->SetValue( int( $data->{'offset'} * 400 ), 1);
    #~ $self->{ 'radius' }->SetValue( $data->{'radius'} * 100, 1 );
    #~ $self->{ 'damp' }->SetValue( $data->{'damp'}, 1 );
    #~ $self->update_enable;
    1;
}

sub update_enable {
    my ($self) = @_;
    #~ my $val = $self->{ 'on' }->IsChecked;
    #~ $self->{$_}->Enable( $val ) for qw/frequency freq_dez invert_freq direction half_off quarter_off offset radius damp/;
}


1;
