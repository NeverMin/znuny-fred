# --
# Kernel/Output/HTML/FredConfigLog.pm - layout backend module
# Copyright (C) 2001-2013 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FredConfigLog;

use strict;
use warnings;

use vars qw(@ISA $VERSION);

=head1 NAME

Kernel::Output::HTML::FredConfigLog - layout backend module

=head1 SYNOPSIS

All layout functions of the config log module

=over 4

=cut

=item new()

create an object

    $BackendObject = Kernel::Output::HTML::FredConfigLog->new(
        %Param,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Object (qw(ConfigObject LogObject LayoutObject)) {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    return $Self;
}

=item CreateFredOutput()

create the output of the translationdebugging log

    $LayoutObject->CreateFredOutput(
        ModulesRef => $ModulesRef,
    );

=cut

sub CreateFredOutput {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ModuleRef} ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => 'Need ModuleRef!',
        );
        return;
    }

    my $HTMLLines = '';
    for my $Line ( @{ $Param{ModuleRef}->{Data} } ) {

        for my $TD ( @{$Line} ) {
            $TD = $Self->{LayoutObject}->Ascii2Html( Text => $TD );
        }

        if ( $Line->[1] eq 'True' ) {
            $Line->[1] = '';
        }

        for my $Count ( 0 .. 3 ) {
            $Line->[$Count] ||= '';
        }

        $HTMLLines .= "        <tr>\n"
            . "          <td align=\"right\">$Line->[3]</td>\n"
            . "          <td>$Line->[0]</td>\n"
            . "          <td>$Line->[1]</td>\n"
            . "          <td>$Line->[2]</td>\n"
            . "        </tr>";
    }

    return if !$HTMLLines;

    $Param{ModuleRef}->{Output} = $Self->{LayoutObject}->Output(
        TemplateFile => 'DevelFredConfigLog',
        Data         => {
            HTMLLines => $HTMLLines,
        },
    );

    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
