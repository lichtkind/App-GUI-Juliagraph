#

package App::GUI::Juliagraph::Frame::Tab::Constraints;
use v5.12;
use warnings;
use Wx;
use base qw/Wx::Panel/;
use App::GUI::Juliagraph::Widget::SliderStep;

sub new {
    my ( $class, $parent) = @_;
    my $self = $class->SUPER::new( $parent, -1);
    $self->{'callback'} = sub {};

    my $coor_assign_lbl  = Wx::StaticText->new($self, -1, 'P i x e l   C o o r d i n a t e s : ' );
    my $const_assign_lbl = Wx::StaticText->new($self, -1, 'C o n s t a n t   V a l u e s : ' );
    my $zoom_lbl   = Wx::StaticText->new($self, -1, 'Z o o m : ' );
    my $pos_lbl    = Wx::StaticText->new($self, -1, 'P o s i t i o n : ' );
    my $x_lbl      = Wx::StaticText->new($self, -1, 'X : ' );
    my $y_lbl      = Wx::StaticText->new($self, -1, 'Y : ' );
    my $const_lbl  = Wx::StaticText->new($self, -1, 'C o n s t a n t :' );
    my $a_lbl      = Wx::StaticText->new($self, -1, 'A : ' );
    my $b_lbl      = Wx::StaticText->new($self, -1, 'B : ' );
    my $stop_lbl   = Wx::StaticText->new($self, -1, 'Iteration Stop' );
    my $stop_val_lbl  = Wx::StaticText->new($self, -1, 'V a l u e : ' );
    my $metric_lbl  = Wx::StaticText->new($self, -1, 'M e t r i c : ' );
    $coor_assign_lbl->SetToolTip("how numeric coordinates are part of computation:\n - not at all\n - as start value of the iteration \n - added as constant at any iteration \n - as factor of monomial of nth degree");
    $const_assign_lbl->SetToolTip("how complex constant below is part of computation:\n - not at all\n - as start value of the iteration \n - added as constant at any iteration");
    $zoom_lbl->SetToolTip('zoom factor: the larger the more you zoom in');
    $pos_lbl->SetToolTip('center position of visible area');
    $const_lbl->SetToolTip('complex constant that will be used according settings in first paragraph');
    $stop_lbl->SetToolTip('abort iteration when variable value is above this boundary');
    $metric_lbl->SetToolTip('metric of iteration variable against which stop value is compared (|var| = z.re**2 + z.i**2)');

    $self->{'type'}     = Wx::RadioBox->new( $self, -1, ' T y p e ', [-1,-1],[-1,-1], ['Julia','Mandelbrot', 'Any'] );
    $self->{'type'}->SetToolTip("choose fractal type: \njulia uses position as init value of iterator var and constant as such, mandelbrot is vice versa\nany means no such restrictions");
    $self->{'position'}    = Wx::ComboBox->new( $self, -1,   '', [-1,-1],[125, -1], [ 'start value', 'constant', 'degree 1', 'degree 2', 'degree 3', 'degree 4', 'degree 5', 'degree 6', 'degree 7']);
    $self->{'position'}->SetToolTip("how numeric coordinates are part of computation:\n - not at all\n - as start value of the iteration \n - added as constant at any iteration \n - as factor of monomial of nth degree");
    $self->{'constant'}    = Wx::ComboBox->new( $self, -1,   '', [-1,-1],[125, -1], ['dismiss', 'start value', 'constant',]);
    $self->{'constant'}->SetToolTip("how complex constant below is part of computation:\n - not at all\n - as start value of the iteration \n - added as constant at any iteration");

    $self->{'zoom'}     = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [ 80, -1] );
    $self->{'pos_x'}    = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'pos_y'}    = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'const_a'}  = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'const_b'}  = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'button_zoom'} = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, );
    $self->{'button_x'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, );
    $self->{'button_y'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, );
    $self->{'button_a'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, );
    $self->{'button_b'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, );
    $self->{'stop_value'}  = Wx::ComboBox->new( $self, -1, 1000, [-1,-1],[95, -1], [20, 40, 70, 100, 200, 500, 1000, 2000, 5000, 10000]);
    $self->{'stop_value'}->SetToolTip('abort iteration when variable value is above this boundary');
    $self->{'stop_metric'} = Wx::ComboBox->new( $self, -1, '|var|', [-1,-1],[95, -1], ['|var|', '|x|+|y|', '|x|', '|y|', '|x+y|', 'x+y', 'x-y', 'y-x', 'x*y', '|x*y|']);
    $self->{'stop_value'}->SetToolTip('with formula is computed with iterator variable before compared with stop value');

    $self->{'button_x'}->SetCallBack(sub { my $value = shift;$self->{'pos_x'}->SetValue( $self->{'pos_x'}->GetValue + ($value * $self->zoom_size) ) });
    $self->{'button_y'}->SetCallBack(sub { my $value = shift;$self->{'pos_y'}->SetValue( $self->{'pos_y'}->GetValue + ($value * $self->zoom_size) ) });
    $self->{'button_a'}->SetCallBack(sub { $self->{'const_a'}->SetValue( $self->{'const_a'}->GetValue + shift ) });
    $self->{'button_b'}->SetCallBack(sub { $self->{'const_b'}->SetValue( $self->{'const_b'}->GetValue + shift ) });    $self->{'button_zoom'}->SetCallBack(sub { $self->{'zoom'}->SetValue( $self->{'zoom'}->GetValue + shift ) });

    Wx::Event::EVT_RADIOBOX( $self, $self->{'type'},  sub {
        my $sel = $self->{'type'}->GetStringSelection;
        if    ($sel eq 'Julia')     { $self->set_settings( {position => 'start value', constant => 'constant'} ) }
        elsif ($sel eq 'Mandelbrot'){ $self->set_settings( {position => 'constant', constant => 'start value'} ) }
        if    ($sel eq 'Any')       { $self->{'constant'}->Enable(1); $self->{'position'}->Enable(1); }
        else                        { $self->{'constant'}->Enable(0); $self->{'position'}->Enable(0); }
        $self->{'callback'}->();
    });
    Wx::Event::EVT_TEXT( $self, $self->{$_},          sub { $self->{'callback'}->() }) for qw/const_a const_b pos_x pos_y zoom/;
    Wx::Event::EVT_COMBOBOX( $self, $self->{$_},      sub { $self->{'callback'}->() }) for qw/constant position stop_value stop_metric/;

    my $std  = &Wx::wxALIGN_LEFT | &Wx::wxALIGN_CENTER_VERTICAL | &Wx::wxGROW;
    my $box  = $std | &Wx::wxTOP | &Wx::wxBOTTOM;
    my $item = $std | &Wx::wxLEFT;
    my $row  = $std | &Wx::wxTOP;
    my $all  = $std | &Wx::wxALL;

    my $left_margin = 20;
    my $type_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $type_sizer->AddSpacer( $left_margin );
    $type_sizer->Add( $self->{'type'},      0, $box,  0);
    $type_sizer->AddSpacer( 36 );
    $type_sizer->Add( $coor_assign_lbl,     0, $box, 14);
    $type_sizer->AddSpacer(  5 );
    $type_sizer->Add( $self->{'position'},  0, $box,  6);
    $type_sizer->AddStretchSpacer( );

    my $const_assign_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $const_assign_sizer->AddSpacer( $left_margin );
    $const_assign_sizer->AddSpacer( 242 );
    $const_assign_sizer->Add( $const_assign_lbl,    0, $box, 12);
    $const_assign_sizer->AddSpacer( 17 );
    $const_assign_sizer->Add( $self->{'constant'},  0, $box,  5);
    $const_assign_sizer->AddStretchSpacer( );

    my $zoom_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $zoom_sizer->AddSpacer( $left_margin );
    $zoom_sizer->Add( $self->{'zoom'},        1, $box, 10);
    $zoom_sizer->Add( $self->{'button_zoom'}, 0, $box, 10);
    $zoom_sizer->AddSpacer( $left_margin );

    my $x_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $x_sizer->AddSpacer( $left_margin );
    $x_sizer->Add( $x_lbl,              0, $row, 12);
    $x_sizer->AddSpacer( 10 );
    $x_sizer->Add( $self->{'pos_x'},    1, $box, 5);
    $x_sizer->Add( $self->{'button_x'}, 0, $box, 5);
    $x_sizer->AddSpacer( $left_margin );

    my $y_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $y_sizer->AddSpacer( $left_margin );
    $y_sizer->Add( $y_lbl,              0, $row, 17);
    $y_sizer->AddSpacer( 10 );
    $y_sizer->Add( $self->{'pos_y'},    1, $box, 10);
    $y_sizer->Add( $self->{'button_y'}, 0, $box, 10);
    $y_sizer->AddSpacer( $left_margin );

    my $a_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $a_sizer->AddSpacer( $left_margin );
    $a_sizer->Add( $a_lbl,              0, $row, 12);
    $a_sizer->AddSpacer( 10 );
    $a_sizer->Add( $self->{'const_a'},  1, $box,  5);
    $a_sizer->Add( $self->{'button_a'}, 0, $box,  5);
    $a_sizer->AddSpacer( $left_margin );

    my $b_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $b_sizer->AddSpacer( $left_margin );
    $b_sizer->Add( $b_lbl,              0, $row, 17);
    $b_sizer->AddSpacer( 10 );
    $b_sizer->Add( $self->{'const_b'},  1, $box, 10);
    $b_sizer->Add( $self->{'button_b'}, 0, $box, 10);
    $b_sizer->AddSpacer( $left_margin );

    my $stop_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $stop_sizer->AddSpacer( $left_margin );
    $stop_sizer->Add( $stop_val_lbl,          0, $all, 22);
    $stop_sizer->AddSpacer( 10 );
    $stop_sizer->Add( $self->{'stop_value'},  0, $all, 0);
    $stop_sizer->Add( 0, 0, $all );
    $stop_sizer->Add( $metric_lbl,            0, $all, 22);
    $stop_sizer->AddSpacer( 10 );
    $stop_sizer->Add( $self->{'stop_metric'}, 0, $all, 0);
    $stop_sizer->AddSpacer( 10 );
    $stop_sizer->AddSpacer( $left_margin );

    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
    $sizer->Add( $type_sizer,           0, $row, 10);
    $sizer->Add( $const_assign_sizer,   0, $row,  3);
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $box, 10 );
    $sizer->Add( $zoom_lbl,    0, $item, $left_margin);
    $sizer->Add( $zoom_sizer,  0, $row, 2);
    $sizer->AddSpacer(  5 );
    $sizer->Add( $pos_lbl,     0, $item, $left_margin);
    $sizer->Add( $x_sizer,     0, $row, 2);
    $sizer->Add( $y_sizer,     0, $row, 0);
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $box, 10 );
    $sizer->Add( $const_lbl,   0, $item, $left_margin);
    $sizer->Add( $a_sizer,     0, $row, 2);
    $sizer->Add( $b_sizer,     0, $row, 0);
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $box, 10 );
    $sizer->Add( $stop_lbl,    0, &Wx::wxALIGN_CENTER_HORIZONTAL , 5);
    $sizer->Add( $stop_sizer,  0, $box, 0);
    $sizer->AddSpacer( $left_margin );
    $self->SetSizer($sizer);

    $self->init();
    $self;
}

sub init {
    my ( $self ) = @_;
    $self->set_settings ({ type => 'Mandelbrot', constant => 'start value', position => 'constant',
           zoom => 0, pos_x => 0, pos_y => 0,
           const_a => 0, const_b => 0, stop_value => 1000, stop_metric => '|var|' } );
    $self->{'constant'}->Enable(0);
    $self->{'position'}->Enable(0);
}

sub get_settings {
    my ( $self ) = @_;
    {
        zoom    => $self->{'zoom'}->GetValue  + 0,
        pos_x   => $self->{'pos_x'}->GetValue + 0,
        pos_y   => $self->{'pos_y'}->GetValue + 0,
        const_a => $self->{'const_a'}->GetValue + 0,
        const_b => $self->{'const_b'}->GetValue + 0,
        type    => $self->{'type'}->GetStringSelection,
        position => $self->{'position'}->GetStringSelection,
        constant => $self->{'constant'}->GetStringSelection,
        stop_value  => $self->{'stop_value'}->GetStringSelection,
        stop_metric => $self->{'stop_metric'}->GetStringSelection,
    }
}

sub set_settings {
    my ( $self, $data ) = @_;
    return 0 unless ref $data eq 'HASH' and exists $data->{'position'};
    $self->PauseCallBack();
    for my $key (qw/const_a const_b pos_x pos_y zoom/){
        next unless exists $data->{$key} and exists $self->{$key};
        $self->{$key}->SetValue( $data->{$key} );
    }
    for my $key (qw/type position constant stop_value stop_metric/){
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
