
# part of a polynomial tab

package App::GUI::Juliagraph::Frame::Panel::Monomial;
use v5.12;
use warnings;
use Wx;
use base qw/Wx::Panel/;
use App::GUI::Juliagraph::Widget::SliderStep;

sub new {
    my ( $class, $parent, $initial_exp, $std_margin ) = @_;

    my $self = $class->SUPER::new( $parent, -1 );
    $self->{'init_exp'} = $initial_exp // 0;
    $self->{'callback'} = sub {};

    $self->{'active'} = Wx::CheckBox->new( $self, -1, ' On', [-1,-1], [ 70, -1]);
    $self->{'active'}->SetToolTip("switch thit polynome on or off");

    $self->{'use_factor'} = Wx::CheckBox->new( $self, -1, ' Factor', [-1,-1], [ 80, -1]);
    $self->{'use_factor'}->SetToolTip('use or discard factor in formula z_n+1 = z_n**exp * factor');

    $self->{'use_log'} = Wx::CheckBox->new( $self, -1, ' log', [-1,-1], [ 60, -1]);
    $self->{'use_log'}->SetToolTip(' if in you put a log in fornt of this monomial term');

    my $exp_txt = "exponent above iterator variable z_n+1 = z_n**exponent * factor\nzero turns factor into constant";
    my $exp_lbl   = Wx::StaticText->new($self, -1, 'E x p o n e n t :' );
    $exp_lbl->SetToolTip($exp_txt);
    $self->{'exponent'} = Wx::ComboBox->new( $self, -1, 2, [-1,-1],[75, 35], [1 .. 16]);
    $self->{'exponent'}->SetToolTip($exp_txt);

    my $r_lbl     = Wx::StaticText->new($self, -1, 'Re : ' );
    my $i_lbl     = Wx::StaticText->new($self, -1, 'Im : ' );
    $r_lbl->SetToolTip('real value part of factor');
    $i_lbl->SetToolTip('imaginary value part of factor');
    $self->{'factor_r'}  = Wx::TextCtrl->new( $self, -1, 0, [-1, -1],  [-1, 30] );
    $self->{'factor_i'}  = Wx::TextCtrl->new( $self, -1, 0, [-1, -1],  [-1, 30] );
    $self->{'factor_r'}->SetToolTip('real value part of factor');
    $self->{'factor_i'}->SetToolTip('imaginary value part of factor');
    $self->{'button_r'}  = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 100, 3, 0.3, 2, );
    $self->{'button_i'}  = App::GUI::Juliagraph::Widget::SliderStep->new( $self, 100, 3, 0.3, 2, );

    $self->{'button_r'}->SetCallBack(sub { $self->{'factor_r'}->SetValue( $self->{'factor_r'}->GetValue + shift ) });
    $self->{'button_i'}->SetCallBack(sub { $self->{'factor_i'}->SetValue( $self->{'factor_i'}->GetValue + shift ) });


    Wx::Event::EVT_CHECKBOX( $self, $self->{$_}, sub { $self->{'callback'}->() }) for qw/active use_factor/;
    Wx::Event::EVT_COMBOBOX( $self, $self->{$_}, sub { $self->{'callback'}->() }) for qw/exponent/;
    Wx::Event::EVT_TEXT( $self, $self->{$_},     sub { $self->{'callback'}->() }) for qw/factor_r factor_i/;


    $std_margin //= 10;
    my $std  = &Wx::wxALIGN_LEFT | &Wx::wxALIGN_CENTER_VERTICAL | &Wx::wxGROW;
    my $box  = $std | &Wx::wxTOP | &Wx::wxBOTTOM;
    my $item = $std | &Wx::wxLEFT | &Wx::wxRIGHT;
    my $row  = $std | &Wx::wxTOP;
    my $first_sizer = Wx::BoxSizer->new( &Wx::wxHORIZONTAL );
    $first_sizer->AddSpacer( $std_margin );
    $first_sizer->Add( $self->{'active'},     0, $box,  5);
    $first_sizer->AddSpacer( $std_margin );
    $first_sizer->Add( $self->{'use_factor'}, 0, $box,  5);
    $first_sizer->AddSpacer( $std_margin );
    $first_sizer->Add( $self->{'use_log'},    0, $box,  5);
    $first_sizer->AddStretchSpacer( );
    $first_sizer->Add( $exp_lbl,              0, $box, 12);
    $first_sizer->AddSpacer( 10 );
    $first_sizer->Add( $self->{'exponent'},   0, $box,  5);
    $first_sizer->AddSpacer( $std_margin );

    my $r_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $r_sizer->AddSpacer( $std_margin );
    $r_sizer->Add( $r_lbl,              0, $box, 12);
    $r_sizer->AddSpacer( 5 );
    $r_sizer->Add( $self->{'factor_r'}, 1, $box,  5);
    $r_sizer->Add( $self->{'button_r'}, 0, $box,  5);
    $r_sizer->AddSpacer( $std_margin );

    my $i_sizer = Wx::BoxSizer->new(&Wx::wxHORIZONTAL);
    $i_sizer->AddSpacer( $std_margin );
    $i_sizer->Add( $i_lbl,              0, $box, 12);
    $i_sizer->AddSpacer( 5 );
    $i_sizer->Add( $self->{'factor_i'}, 1, $box,  5);
    $i_sizer->Add( $self->{'button_i'}, 0, $box,  5);
    $i_sizer->AddSpacer( $std_margin );

    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
    $sizer->Add( $first_sizer, 0, $row, 0 );
    $sizer->Add( $r_sizer,     0, $row, 5 );
    $sizer->Add( $i_sizer,     0, $row, 0 );
    $sizer->AddSpacer( 10 );
    $self->SetSizer($sizer);
    $self;
}

sub init {
    my ( $self ) = @_;
    $self->set_settings ({ exponent => $self->{'init_exp'},
                           factor_r => 1, factor_i => 1, active => 0, use_factor => 1 } );
}
sub get_settings {
    my ( $self ) = @_;
    {
        active     => $self->{'active'}->GetValue   ? $self->{'active'}->GetValue : 0,
        use_factor => $self->{'use_factor'}->GetValue ? $self->{'use_factor'}->GetValue : 0,
        use_log    => $self->{'use_log'}->GetValue ? $self->{'use_log'}->GetValue : 0,
        factor_r   => $self->{'factor_r'}->GetValue ? $self->{'factor_r'}->GetValue : 0,
        factor_i   => $self->{'factor_i'}->GetValue ? $self->{'factor_i'}->GetValue : 0,
        exponent   => $self->{'exponent'}->GetStringSelection,
    }
}
sub set_settings {
    my ( $self, $data ) = @_;
    return 0 unless ref $data eq 'HASH';
    $self->PauseCallBack();
    for my $key (qw/active use_factor use_log factor_r factor_i/){
        next unless exists $data->{$key} and exists $self->{$key};
        $self->{$key}->SetValue( $data->{$key} );
    }
    for my $key (qw/exponent/){
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
