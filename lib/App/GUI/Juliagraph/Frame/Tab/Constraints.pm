#

package App::GUI::Juliagraph::Frame::Tab::Constraints;
use v5.12;
use warnings;
use Wx;
use base qw/Wx::Panel/;
use App::GUI::Juliagraph::Widget::SliderStep;

my $default_settings = {
    type => 'Mandelbrot', coordinates_use => 'constant',
    zoom => 0, center_x => 0, center_y => 0,
    const_a => 0, const_b => 0, start_a => 0, start_b => 0,
    stop_nr => 1000, stop_value => 1000, stop_metric => '|var|'
};

sub new {
    my ( $class, $parent) = @_;
    my $self = $class->SUPER::new( $parent, -1);
    $self->{'callback'} = sub {};
    $self->{'polynome'} = '';

    my $coor_lbl     = Wx::StaticText->new($self, -1, 'P i x e l   C o o r d i n a t e s : ' );
    my $zoom_lbl     = Wx::StaticText->new($self, -1, 'Z o o m : ' );
    my $pos_lbl      = Wx::StaticText->new($self, -1, 'P o s i t i o n : ' );
    my $x_lbl        = Wx::StaticText->new($self, -1, 'X : ' );
    my $y_lbl        = Wx::StaticText->new($self, -1, 'Y : ' );
    $self->{'lbl_const'} = Wx::StaticText->new($self, -1, 'C o n s t a n t :' );
    $self->{'lbl_consta'} = Wx::StaticText->new($self, -1, 'A : ' );
    $self->{'lbl_constb'} = Wx::StaticText->new($self, -1, 'B : ' );
    $self->{'lbl_starta'} = Wx::StaticText->new($self, -1, 'A : ' );
    $self->{'lbl_startb'} = Wx::StaticText->new($self, -1, 'B : ' );
    $self->{'lbl_start'} = Wx::StaticText->new($self, -1, 'S t a r t    V a l u e : ' );
    my $stop_lbl     = Wx::StaticText->new($self, -1, 'I t e r a t i o n   S t o p : ' );
    my $stop_nr_lbl  = Wx::StaticText->new($self, -1, 'M a x : ' );
    my $stop_val_lbl = Wx::StaticText->new($self, -1, 'V a l u e : ' );
    my $metric_lbl   = Wx::StaticText->new($self, -1, 'M e t r i c : ' );
    $coor_lbl->SetToolTip("Which role play pixel coordinates in computation:\n - as start value of the iteration (z_0)\n - added as constant at any iteration \n - as factor of one monomial on next page (numbered from top to bottom)");
    $zoom_lbl->SetToolTip('zoom factor: the larger the more you zoom in');
    $pos_lbl->SetToolTip('center coordinates of visible sector');
    $self->{'lbl_const'}->SetToolTip('complex constant that will be used according settings in first paragraph');
    $self->{'lbl_start'}->SetToolTip('value of iteration variable Z before first iteration');
    $stop_lbl->SetToolTip('conditions that stop the iteration (computation of pixel color)');
    $stop_nr_lbl->SetToolTip('maximal amount of iterations run on one pixel coordinates');
    $stop_val_lbl->SetToolTip('stop value: when iteration variable Z reaches or exceeds it computation will be stopped and count of iterations needed will determine the color of that pixel');
    $metric_lbl->SetToolTip('metric for computing stop value (|var| = sqrt(z.re**2 + z.i**2), x = z.real, y = z.im');

    $self->{'type'} = Wx::RadioBox->new( $self, -1, ' T y p e ', [-1,-1], [-1,-1], ['Julia','Mandelbrot', 'Any'] );
    $self->{'type'}->SetToolTip( "choose fractal type: \njulia uses position as init value of iterator var and constant as such, mandelbrot is vice versa\nany means no such restrictions" );
    $self->{'coordinates_use'} = Wx::ComboBox->new( $self, -1, '', [-1,-1], [125, -1], [ 'start value', 'constant', 'monomial 1', 'monomial 2', 'monomial 3', 'monomial 4']);
    $self->{'coordinates_use'}->SetToolTip("Which role play pixel coordinates in computation:\n - as start value of the iteration (z_0)\n - added as constant at any iteration \n - as factor of one monomial on next page (numbered from top to bottom)");

    $self->{'zoom'}     = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [ 80, -1] );
    $self->{'center_x'} = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'center_y'} = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'const_a'}  = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'const_b'}  = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'start_a'}  = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'start_b'}  = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'button_zoom'} = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 120, 3, 0.3, 3, 3);
    $self->{'button_x'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 120, 3, 0.3, 3, 3);
    $self->{'button_y'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 120, 3, 0.3, 3, 3);
    $self->{'button_ca'}   = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 120, 3, 0.3, 3, 3);
    $self->{'button_cb'}   = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 120, 3, 0.3, 3, 3);
    $self->{'button_sa'}   = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 120, 3, 0.3, 3, 3);
    $self->{'button_sb'}   = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 120, 3, 0.3, 3, 3);
    $self->{'button_zoom'}->SetToolTip('zoom factor: the larger the more you zoom in');
    $self->{'button_zoom'}->SetCallBack(sub { $self->{'zoom'}->SetValue( $self->{'zoom'}->GetValue + shift ) });
    $self->{'button_x'}->SetCallBack( sub { my $value = shift;$self->{'center_x'}->SetValue( $self->{'center_x'}->GetValue + ($value * $self->zoom_size) ) });
    $self->{'button_y'}->SetCallBack( sub { my $value = shift;$self->{'center_y'}->SetValue( $self->{'center_y'}->GetValue + ($value * $self->zoom_size) ) });
    $self->{'button_ca'}->SetCallBack(sub { $self->{'const_a'}->SetValue( $self->{'const_a'}->GetValue + shift ) });
    $self->{'button_cb'}->SetCallBack(sub { $self->{'const_b'}->SetValue( $self->{'const_b'}->GetValue + shift ) });
    $self->{'button_sa'}->SetCallBack(sub { $self->{'start_a'}->SetValue( $self->{'start_a'}->GetValue + shift ) });
    $self->{'button_sb'}->SetCallBack(sub { $self->{'start_b'}->SetValue( $self->{'start_b'}->GetValue + shift ) });

    $self->{'stop_nr'}   = Wx::ComboBox->new( $self, -1, 1000, [-1,-1],[95, -1], [20, 40, 70, 100, 200, 500, 1000, 2000, 5000, 10000, 20000]);
    $self->{'stop_nr'}->SetToolTip('maximal amount of iterations run on one pixel coordinates');
    $self->{'stop_value'}  = Wx::ComboBox->new( $self, -1, 1000, [-1,-1],[95, -1], [20, 40, 70, 100, 200, 500, 1000, 2000, 5000, 10000, 20000]);
    $self->{'stop_value'}->SetToolTip('stop value: when iteration variable Z reaches or exceeds it computation will be stopped and count of iterations needed will determine the color of that pixel');
    $self->{'stop_metric'} = Wx::ComboBox->new( $self, -1, '|var|', [-1,-1],[95, -1], ['|var|', '|x|+|y|', '|x|', '|y|', '|x+y|', 'x+y', 'x-y', 'y-x', 'x*y', '|x*y|']);
    $self->{'stop_metric'}->SetToolTip('metric for computing stop value (|var| = sqrt(z.re**2 + z.i**2), x = z.real, y = z.im');

    $self->{'const_widgets'} = [qw/const_a const_b button_ca button_cb lbl_const lbl_consta lbl_constb/];
    $self->{'start_widgets'} = [qw/start_a start_b button_sa button_sb lbl_start lbl_starta lbl_startb/];

    Wx::Event::EVT_RADIOBOX( $self, $self->{'type'},  sub {
        $self->set_type( $self->{'type'}->GetStringSelection );
        $self->{'callback'}->();
    });
    Wx::Event::EVT_COMBOBOX( $self, $self->{'coordinates_use'}, sub {
        $self->set_coordinates_use( $self->{'coordinates_use'}->GetStringSelection );
        $self->{'callback'}->();
    });
    Wx::Event::EVT_TEXT( $self, $self->{$_},          sub { $self->{'callback'}->() }) for qw/const_a const_b center_x center_y zoom/;
    Wx::Event::EVT_COMBOBOX( $self, $self->{$_},      sub { $self->{'callback'}->() }) for qw/stop_value stop_metric/;

    my $std  = &Wx::wxALIGN_LEFT | &Wx::wxALIGN_CENTER_VERTICAL | &Wx::wxGROW;
    my $box  = $std | &Wx::wxTOP | &Wx::wxBOTTOM;
    my $item = $std | &Wx::wxLEFT;
    my $row  = $std | &Wx::wxTOP;
    my $all  = $std | &Wx::wxALL;

    my $left_margin = 20;
    my $type_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $type_sizer->AddSpacer( $left_margin );
    $type_sizer->Add( $self->{'type'},            0, $box,  0);
    $type_sizer->AddSpacer( 35 );
    $type_sizer->Add( $coor_lbl,                  0, $row, 15);
    $type_sizer->AddSpacer(  6 );
    $type_sizer->Add( $self->{'coordinates_use'}, 0, $row,  5);
    $type_sizer->AddStretchSpacer( );

    my $zoom_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $zoom_sizer->AddSpacer( $left_margin );
    $zoom_sizer->Add( $self->{'zoom'},        1, $box, 10);
    $zoom_sizer->Add( $self->{'button_zoom'}, 0, $box, 10);
    $zoom_sizer->AddSpacer( $left_margin );

    my $x_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $x_sizer->AddSpacer( $left_margin );
    $x_sizer->Add( $x_lbl,              0, $row, 12);
    $x_sizer->AddSpacer( 10 );
    $x_sizer->Add( $self->{'center_x'}, 1, $box, 5);
    $x_sizer->Add( $self->{'button_x'}, 0, $box, 5);
    $x_sizer->AddSpacer( $left_margin );

    my $y_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $y_sizer->AddSpacer( $left_margin );
    $y_sizer->Add( $y_lbl,              0, $row, 17);
    $y_sizer->AddSpacer( 10 );
    $y_sizer->Add( $self->{'center_y'}, 1, $box, 10);
    $y_sizer->Add( $self->{'button_y'}, 0, $box, 10);
    $y_sizer->AddSpacer( $left_margin );

    my $const_a_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $const_a_sizer->AddSpacer( $left_margin );
    $const_a_sizer->Add( $self->{'lbl_consta'}, 0, $row, 12);
    $const_a_sizer->AddSpacer( 10 );
    $const_a_sizer->Add( $self->{'const_a'},   1, $box,  5);
    $const_a_sizer->Add( $self->{'button_ca'}, 0, $box,  5);
    $const_a_sizer->AddSpacer( $left_margin );

    my $const_b_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $const_b_sizer->AddSpacer( $left_margin );
    $const_b_sizer->Add( $self->{'lbl_constb'}, 0, $row, 17);
    $const_b_sizer->AddSpacer( 10 );
    $const_b_sizer->Add( $self->{'const_b'},   1, $box, 10);
    $const_b_sizer->Add( $self->{'button_cb'}, 0, $box, 10);
    $const_b_sizer->AddSpacer( $left_margin );

    my $start_a_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $start_a_sizer->AddSpacer( $left_margin );
    $start_a_sizer->Add( $self->{'lbl_starta'}, 0, $row, 17);
    $start_a_sizer->AddSpacer( 10 );
    $start_a_sizer->Add( $self->{'start_a'},   1, $box, 10);
    $start_a_sizer->Add( $self->{'button_sa'}, 0, $box, 10);
    $start_a_sizer->AddSpacer( $left_margin );

    my $start_b_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $start_b_sizer->AddSpacer( $left_margin );
    $start_b_sizer->Add( $self->{'lbl_startb'}, 0, $row, 17);
    $start_b_sizer->AddSpacer( 10 );
    $start_b_sizer->Add( $self->{'start_b'},   1, $box, 10);
    $start_b_sizer->Add( $self->{'button_sb'}, 0, $box, 10);
    $start_b_sizer->AddSpacer( $left_margin );

    my $stop_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $stop_sizer->AddSpacer( $left_margin );
    $stop_sizer->Add( $stop_nr_lbl,           0, $box, 12);
    $stop_sizer->AddSpacer(  5 );
    $stop_sizer->Add( $self->{'stop_nr'},     0, $box,  5);
    $stop_sizer->AddSpacer( 50 );
    $stop_sizer->Add( $stop_val_lbl,          0, $box, 12);
    $stop_sizer->AddSpacer(  5 );
    $stop_sizer->Add( $self->{'stop_value'},  0, $box,  5);
    $stop_sizer->AddSpacer( 25 );
    $stop_sizer->Add( $metric_lbl,            0, $box, 12);
    $stop_sizer->AddSpacer(  5 );
    $stop_sizer->Add( $self->{'stop_metric'}, 0, $box,  5);
    $stop_sizer->AddSpacer( 10 );
    $stop_sizer->AddSpacer( $left_margin );

    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
    $sizer->Add( $type_sizer,      0, $row, 10);
    $sizer->AddSpacer(  3 );
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $box, 10 );
    $sizer->Add( $zoom_lbl,        0, $item, $left_margin);
    $sizer->Add( $zoom_sizer,      0, $row, 2);
    $sizer->AddSpacer(  5 );
    $sizer->Add( $pos_lbl,         0, $item, $left_margin);
    $sizer->Add( $x_sizer,         0, $row, 6);
    $sizer->Add( $y_sizer,         0, $row, 0);
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $box, 10 );
    $sizer->Add( $self->{'lbl_const'}, 0, $item, $left_margin);
    $sizer->Add( $const_a_sizer,   0, $row, 6);
    $sizer->Add( $const_b_sizer,   0, $row, 0);
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $box, 10 );
    $sizer->Add( $self->{'lbl_start'}, 0, $item, $left_margin);
    $sizer->Add( $start_a_sizer,   0, $row, 6);
    $sizer->Add( $start_b_sizer,   0, $row, 0);
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $box, 10 );
    $sizer->Add( $stop_lbl,        0, $item, $left_margin);
    $sizer->Add( $stop_sizer,      0, $row,  6);
    $sizer->AddSpacer( $left_margin );
    $self->SetSizer($sizer);

    $self->init();
    $self;
}

sub init {
    my ( $self ) = @_;
    $self->set_settings ( $default_settings );
}

sub get_settings {
    my ( $self ) = @_;
    {
        zoom     => $self->{'zoom'}->GetValue  + 0,
        center_x => $self->{'center_x'}->GetValue + 0,
        center_y => $self->{'center_y'}->GetValue + 0,
        const_a  => $self->{'const_a'}->GetValue + 0,
        const_b  => $self->{'const_b'}->GetValue + 0,
        start_a  => $self->{'start_a'}->GetValue + 0,
        start_b  => $self->{'start_b'}->GetValue + 0,
        type     => $self->{'type'}->GetStringSelection,
        coordinates_use => $self->{'coordinates_use'}->GetStringSelection,
        stop_nr  => $self->{'stop_nr'}->GetStringSelection,
        stop_value => $self->{'stop_value'}->GetStringSelection,
        stop_metric => $self->{'stop_metric'}->GetStringSelection,
    }
}

sub set_settings {
    my ( $self, $settings ) = @_;
    return 0 unless ref $settings eq 'HASH' and exists $settings->{'type'};
    $self->PauseCallBack();
    for my $key (qw/const_a const_b start_a start_b center_x center_y zoom/){
        next unless exists $settings->{$key} and exists $self->{$key};
        $self->{$key}->SetValue( $settings->{$key} );
    }
    for my $key (qw/coordinates_use stop_nr stop_value stop_metric/){
        next unless exists $settings->{$key} and exists $self->{$key};
        $self->{$key}->SetSelection( $self->{$key}->FindString($settings->{$key}) );
    }
    $self->set_type( $settings->{'type'} );
    $self->RestoreCallBack();
    1;
}

sub set_type {
    my ( $self, $type ) = @_;
    return unless defined $type;
    $type = ucfirst $type;
    my $selection_nr = $self->{'type'}->FindString( $type );
    return unless $selection_nr > -1;
    $self->{'type'}->SetSelection( $selection_nr );
    if ($type eq 'Julia') {
        $self->set_coordinates_use('start value');
        $self->{'coordinates_use'}->Enable(0);
    }
    elsif ($type eq 'Mandelbrot'){
        $self->set_coordinates_use('constant');
        $self->{'coordinates_use'}->Enable(0);
    }
    elsif ($type eq 'Any') { $self->{'coordinates_use'}->Enable(1) }
}

sub set_coordinates_use {
    my ( $self, $usage ) = @_;
    return unless defined $usage;
    $usage = lc $usage;
    my $selection_nr = $self->{'coordinates_use'}->FindString( $usage );
    return unless $selection_nr > -1;
    $self->{'coordinates_use'}->SetSelection( $selection_nr );
    if ($usage eq 'start value') {
        $self->{$_}->Enable(1) for @{$self->{'const_widgets'}};
        $self->{$_}->Enable(0) for @{$self->{'start_widgets'}};
        $self->{'polynome'}->disable_factor( 0 ) if ref $self->{'polynome'};
    }
    elsif ($usage eq 'constant'){
        $self->{$_}->Enable(0) for @{$self->{'const_widgets'}};
        $self->{$_}->Enable(1) for @{$self->{'start_widgets'}};
        $self->{'polynome'}->disable_factor( 0 ) if ref $self->{'polynome'};
    }
    else {
        $self->{$_}->Enable(1) for @{$self->{'const_widgets'}};
        $self->{$_}->Enable(1) for @{$self->{'start_widgets'}};
        my $nr = chop $usage;
        $self->{'polynome'}->disable_factor( $nr ) if ref $self->{'polynome'};
    }
}

sub zoom_size { 10 ** (-$_[0]->{'zoom'}->GetValue) }

sub set_polynome {
    my ($self, $ref) = @_;
    return unless ref $ref eq 'App::GUI::Juliagraph::Frame::Tab::Polynomial';
    $self->{'polynome'} = $ref;
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
