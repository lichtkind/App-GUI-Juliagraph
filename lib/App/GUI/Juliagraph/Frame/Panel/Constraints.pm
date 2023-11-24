use v5.12;
use warnings;
use Wx;

package App::GUI::Juliagraph::Frame::Panel::Constraints;
use base qw/Wx::Panel/;
use App::GUI::Juliagraph::Widget::SliderStep;

sub new {
    my ( $class, $parent) = @_;
    my $self = $class->SUPER::new( $parent, -1);
    $self->{'callback'} = sub {};

    my $exp_lbl   = Wx::StaticText->new($self, -1, 'E x p o n e n t :' );
    my $const_lbl = Wx::StaticText->new($self, -1, 'C o n s t a n t :' );
    my $a_lbl     = Wx::StaticText->new($self, -1, 'A : ' );
    my $b_lbl     = Wx::StaticText->new($self, -1, 'B : ' );
    my $var_lbl   = Wx::StaticText->new($self, -1, 'L i n e a r :' );
    my $c_lbl     = Wx::StaticText->new($self, -1, 'C : ' );
    my $d_lbl     = Wx::StaticText->new($self, -1, 'D : ' );
    my $pos_lbl   = Wx::StaticText->new($self, -1, 'P o s i t i o n : ' );
    my $x_lbl     = Wx::StaticText->new($self, -1, 'X : ' );
    my $y_lbl     = Wx::StaticText->new($self, -1, 'Y : ' );
    my $zoom_lbl  = Wx::StaticText->new($self, -1, 'Z o o m : ' );
    my $stop_lbl  = Wx::StaticText->new($self, -1, 'S t o p : ' );
    my $metric_lbl  = Wx::StaticText->new($self, -1, 'M e t r i c : ' );
    $exp_lbl->SetToolTip('exponent above iterator variable z_n+1 = z_n**exp + c');
    $const_lbl->SetToolTip('constant value which get added on every iteration');
    $var_lbl->SetToolTip('linear factor which gets multiplied with variable and added on every iteration');
    $pos_lbl->SetToolTip('position of visible area');
    $zoom_lbl->SetToolTip('zoom factor: the larger the more you zoom in');
    $stop_lbl->SetToolTip('abort iteration when variable value is above this boundary');
    $metric_lbl->SetToolTip('metric of iteration variable against which stop value is compared (|var| = z.re**2 + z.i**2)');

    $self->{'type'}     = Wx::RadioBox->new( $self, -1, ' T y p e ', [-1,-1],[-1,-1], ['Julia','Mandelbrot','Any'] );
    $self->{'type'}->SetToolTip("choose fractal type: \njulia uses position as init value of iterator var and constant as such, mandelbrot is vice versa");
    $self->{'const_a'}  = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'const_b'}  = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'var_c'}    = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'var_d'}    = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'pos_x'}    = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'pos_y'}    = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [100, -1] );
    $self->{'zoom'}     = Wx::TextCtrl->new( $self, -1, 0, [-1,-1],  [ 80, -1] );
    $self->{'button_a'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, '<<', '>>' );
    $self->{'button_b'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, '<<', '>>' );
    $self->{'button_c'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, '<<', '>>' );
    $self->{'button_d'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, '<<', '>>' );
    $self->{'button_x'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, '<<', '>>' );
    $self->{'button_y'}    = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, '<<', '>>' );
    $self->{'button_zoom'} = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 90, 3, 0.3, 2, '<<', '>>' );
    $self->{'exp'} = Wx::ComboBox->new( $self, -1, 2, [-1,-1],[75, 35], [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
    $self->{'exp'}->SetToolTip('exponent above iterator variable');
    $self->{'stop_value'}   = Wx::ComboBox->new( $self, -1, 1000, [-1,-1],[95, -1], [20, 40, 70, 100, 200, 500, 1000, 2000, 5000, 10000]);
    $self->{'stop_value'}->SetToolTip('abort iteration when variable value is above this boundary');
    $self->{'stop_metric'}   = Wx::ComboBox->new( $self, -1, '|var|', [-1,-1],[95, -1], ['|var|', '|x|+|y|', '|x|', '|y|', '|x+y|', 'x+y', 'x-y', 'y-x', 'x*y', '|x*y|']);

    $self->{'button_a'}->SetCallBack(sub { $self->{'const_a'}->SetValue( $self->{'const_a'}->GetValue + shift ) });
    $self->{'button_b'}->SetCallBack(sub { $self->{'const_b'}->SetValue( $self->{'const_b'}->GetValue + shift ) });
    $self->{'button_c'}->SetCallBack(sub { $self->{'var_c'}->SetValue( $self->{'var_c'}->GetValue + shift ) });
    $self->{'button_d'}->SetCallBack(sub { $self->{'var_d'}->SetValue( $self->{'var_d'}->GetValue + shift ) });
    $self->{'button_x'}->SetCallBack(sub { my $value = shift;$self->{'pos_x'}->SetValue( $self->{'pos_x'}->GetValue + ($value * $self->zoom_size) ) });
    $self->{'button_y'}->SetCallBack(sub { my $value = shift;$self->{'pos_y'}->SetValue( $self->{'pos_y'}->GetValue + ($value * $self->zoom_size) ) });
    $self->{'button_zoom'}->SetCallBack(sub { $self->{'zoom'}->SetValue( $self->{'zoom'}->GetValue + shift ) });

    Wx::Event::EVT_RADIOBOX( $self, $self->{'type'},  sub { $self->{'callback'}->() });
    Wx::Event::EVT_TEXT( $self, $self->{$_},          sub { $self->{'callback'}->() }) for qw/const_a const_b var_c var_d pos_x pos_y zoom/;
    Wx::Event::EVT_COMBOBOX( $self, $self->{$_},      sub { $self->{'callback'}->() }) for qw/exp stop_value stop_metric/;

    my $vert_prop = &Wx::wxALIGN_LEFT|&Wx::wxTOP|&Wx::wxBOTTOM|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxALIGN_CENTER_HORIZONTAL;
    my $item_prop = &Wx::wxALIGN_LEFT|&Wx::wxLEFT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxALIGN_CENTER_HORIZONTAL|&Wx::wxGROW;
    my $lbl_prop = &Wx::wxALIGN_LEFT|&Wx::wxGROW|&Wx::wxALL;
    my $txt_prop = &Wx::wxALIGN_LEFT|&Wx::wxLEFT|&Wx::wxRIGHT|&Wx::wxALIGN_CENTER_VERTICAL|&Wx::wxGROW;
    my $std_margin = 10;

    my $type_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $type_sizer->AddSpacer( $std_margin );
    $type_sizer->Add( $self->{'type'}, 0, $vert_prop, 10);
    $type_sizer->AddStretchSpacer( );
    $type_sizer->Add( $exp_lbl,          0, $vert_prop, 20);
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

    my $c_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $c_sizer->AddSpacer( $std_margin );
    $c_sizer->Add( $c_lbl,          0, $vert_prop, 12);
    $c_sizer->AddSpacer( 5 );
    $c_sizer->Add( $self->{'var_c'},  1, $vert_prop, 0);
    $c_sizer->AddSpacer( 5 );
    $c_sizer->Add( $self->{'button_c'}, 0, $item_prop, 0);
    $c_sizer->AddSpacer( $std_margin );

    my $d_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $d_sizer->AddSpacer( $std_margin );
    $d_sizer->Add( $d_lbl,          0, $vert_prop, 12);
    $d_sizer->AddSpacer( 5 );
    $d_sizer->Add( $self->{'var_d'},  1, $vert_prop, 0);
    $d_sizer->AddSpacer( 5 );
    $d_sizer->Add( $self->{'button_d'}, 0, $item_prop, 0);
    $d_sizer->AddSpacer( $std_margin );

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

    my $stop_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $stop_sizer->AddSpacer( $std_margin );
    $stop_sizer->Add( $stop_lbl,  0, $vert_prop, 22);
    $stop_sizer->AddSpacer( 10 );
    $stop_sizer->Add( $self->{'stop_value'},  0, $vert_prop, 0);
    $stop_sizer->Add( 0, 0, $lbl_prop );
    $stop_sizer->Add( $metric_lbl,  0, $vert_prop, 22);
    $stop_sizer->AddSpacer( 10 );
    $stop_sizer->Add( $self->{'stop_metric'},  0, $vert_prop, 0);
    $stop_sizer->AddSpacer( 10 );
    $stop_sizer->AddSpacer( $std_margin );

    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
    $sizer->Add( $type_sizer,  0, $item_prop, 0);
    $sizer->AddSpacer( 5 );
    $sizer->Add( $const_lbl,  0, $lbl_prop, $std_margin);
    $sizer->AddSpacer( 5 );
    $sizer->Add( $a_sizer,  0, $item_prop, 0);
    $sizer->AddSpacer( 20 );
    $sizer->Add( $b_sizer,  0, $item_prop, 0);
    $sizer->AddSpacer( 15 );
    $sizer->Add( $var_lbl,  0, $lbl_prop, $std_margin);
    $sizer->AddSpacer( 5 );
    $sizer->Add( $c_sizer,  0, $item_prop, 0);
    $sizer->AddSpacer( 20 );
    $sizer->Add( $d_sizer,  0, $item_prop, 0);
    $sizer->AddSpacer( 15 );
    $sizer->Add( $pos_lbl,  0, $lbl_prop, $std_margin);
    $sizer->AddSpacer( 5 );
    $sizer->Add( $x_sizer,  0, $item_prop, 0);
    $sizer->AddSpacer( 20 );
    $sizer->Add( $y_sizer,   0, $item_prop, 0);
    $sizer->AddSpacer( 15 );
    $sizer->Add( $zoom_lbl,   0, $lbl_prop, $std_margin);
    $sizer->AddSpacer( 5 );
    $sizer->Add( $zoom_sizer,  0, $item_prop, 0);
    $sizer->AddSpacer( 10 );
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $lbl_prop, 10 );
    $sizer->Add( $stop_sizer,  0, $item_prop, 0);
    $sizer->AddSpacer( $std_margin );
    $self->SetSizer($sizer);

    $self->init();
    $self;
}

sub init {
    my ( $self ) = @_;
    $self->set_settings ({ type => 'Mandelbrot', exp => 2,
                       const_a => 0, const_b => 0, var_c => 0, var_d => 0,
                       pos_x => 0, pos_y => 0, zoom => 0, stop_value => 1000, stop_metric => '|var|' } );
}

sub get_settings {
    my ( $self ) = @_;
    {
        type    => $self->{'type'}->GetString( $self->{'type'}->GetSelection ),
        const_a => $self->{'const_a'}->GetValue ? $self->{'const_a'}->GetValue : 0,
        const_b => $self->{'const_b'}->GetValue ? $self->{'const_b'}->GetValue : 0,
        var_c   => $self->{'var_c'}->GetValue ? $self->{'var_c'}->GetValue : 0,
        var_d   => $self->{'var_d'}->GetValue ? $self->{'var_d'}->GetValue : 0,
        pos_x   => $self->{'pos_x'}->GetValue ? $self->{'pos_x'}->GetValue : 0,
        pos_y   => $self->{'pos_y'}->GetValue ? $self->{'pos_y'}->GetValue : 0,
        zoom    => $self->{'zoom'}->GetValue ? $self->{'zoom'}->GetValue : 0,
        exp     => $self->{'exp'}->GetStringSelection,
        stop_value  => $self->{'stop_value'}->GetStringSelection,
        stop_metric => $self->{'stop_metric'}->GetStringSelection,
    }
}

sub set_settings {
    my ( $self, $data ) = @_;
    return 0 unless ref $data eq 'HASH' and exists $data->{'pos_x'};
    $self->PauseCallBack();
    for my $key (qw/const_a const_b var_c var_d pos_x pos_y zoom/){
        next unless exists $data->{$key} and exists $self->{$key};
        $self->{$key}->SetValue( $data->{$key} );
    }
    for my $key (qw/type exp stop_value stop_metric/){
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
