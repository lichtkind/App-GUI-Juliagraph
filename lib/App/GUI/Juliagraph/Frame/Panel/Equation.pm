use v5.12;
use warnings;
use Wx;

package App::GUI::Juliagraph::Frame::Panel::Equation;
use base qw/Wx::Panel/;

use App::GUI::Juliagraph::Frame::Part::Monome;

sub new {
    my ( $class, $parent) = @_;
    my $self = $class->SUPER::new( $parent, -1);
    $self->{'callback'} = sub {};

    $self->{'1'} = App::GUI::Juliagraph::Frame::Part::Monome->new( $self);
    $self->{'2'} = App::GUI::Juliagraph::Frame::Part::Monome->new( $self);
    $self->{'3'} = App::GUI::Juliagraph::Frame::Part::Monome->new( $self);
    $self->{'4'} = App::GUI::Juliagraph::Frame::Part::Monome->new( $self);

    my $base_attr = &Wx::wxALIGN_LEFT | &Wx::wxALIGN_CENTER_VERTICAL | &Wx::wxGROW;
    my $vert_attr = $base_attr | &Wx::wxTOP | &Wx::wxBOTTOM;
    my $all_attr  = $base_attr | &Wx::wxALL;

    my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
    $sizer->AddSpacer( 5 );
    $sizer->Add( $self->{'1'},                    1, $all_attr, 5);
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $all_attr, 5);
    $sizer->Add( $self->{'2'},                    1, $all_attr, 5);
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $all_attr, 5);
    $sizer->Add( $self->{'3'},                    1, $all_attr, 5);
    $sizer->Add( Wx::StaticLine->new( $self, -1), 0, $all_attr, 5);
    $sizer->Add( $self->{'4'},                    1, $all_attr, 5);
    $sizer->Add( 0, 0, &Wx::wxEXPAND | &Wx::wxGROW);
    $self->SetSizer($sizer);

    $self->init();
    $self;
}

sub init {
    my ( $self ) = @_;
    $self->set_settings ({
                          } );
}

sub get_settings {
    my ( $self ) = @_;
    {
        #zoom    => $self->{'zoom'}->GetValue ? $self->{'zoom'}->GetValue : 0,
        #exp     => $self->{'exp'}->GetStringSelection,
    }
}

sub set_settings {
    my ( $self, $data ) = @_;
    return 0 unless ref $data eq 'HASH' and exists $data->{'monome_1_active'};
    for my $key (qw//){
        next unless exists $data->{$key} and exists $self->{$key};
        $self->{$key}->SetValue( $data->{$key} );
    }
    for my $key (qw//){
        next unless exists $data->{$key} and exists $self->{$key};
        $self->{$key}->SetSelection( $self->{$key}->FindString($data->{$key}) );
    }
    1;
}

sub SetCallBack {
    my ($self, $code) = @_;
    return unless ref $code eq 'CODE';
    $self->{$_}->SetCallBack($code) for 1 .. 4
}

1;
