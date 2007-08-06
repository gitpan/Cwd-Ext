package Cwd::Ext;
use strict;
use Exporter;
use Carp;
use Cwd;

use vars qw(@ISA @EXPORT_OK $VERSION @EXPORT $VERSION);
@ISA = qw/Exporter/;
push @EXPORT_OK,  qw(abs_path_is_in abs_path_is_in_nd abs_path_nd);
our $VERSION = sprintf "%d.%02d", q$Revision: 1.2 $ =~ /(\d+)/g;
$Cwd::Ext::DEBUG =0;
sub DEBUG : lvalue { $Cwd::Ext::DEBUG }

sub abs_path_nd {   
   my $absPath = shift;
    return $absPath if $absPath =~ m{^/$};
   
   $absPath=~/^\// or $absPath = cwd()."/$absPath";
    
    my @elems = split m{/}, $absPath;
    my $ptr = 1;
    while($ptr <= $#elems)
    {
        if($elems[$ptr] eq q{})
        {
            splice @elems, $ptr, 1;
        }
        elsif($elems[$ptr] eq q{.})
        {
            splice @elems, $ptr, 1;
        }
        elsif($elems[$ptr] eq q{..})
        {
            if($ptr < 2)
            {
                splice @elems, $ptr, 1;
            }
            else
            {
                $ptr--;
                splice @elems, $ptr, 2;
            }
        }
        else
        {
            $ptr++;
        }
    }
    return $#elems ? join q{/}, @elems : q{/};
}


sub abs_path_is_in {
   my($child,$parent) = @_;
   defined $child or croak('missing child path argument');
   defined $parent or croak('missing parent path argument');

   my $_child  = Cwd::abs_path($child)  or croak("cant normalize child [$child]");
   my $_parent = Cwd::abs_path($parent) or croak("cant normalize parent [$parent]");

   
   if ($_child eq $_parent){
      warn(" -[$_child] same as [$_parent]");
      return 1;
   }   
   
   # WE DONT WANT /home/hi to match on /home/hithere 
   unless( $_child=~/^$_parent\// ){
      warn (" -[$_child] is not a child of [$_parent]") if DEBUG;
      return 0;
   }
   return $_child;
}


sub abs_path_is_in_nd {
   my($child,$parent) = @_;
   defined $child or croak('missing child path argument');
   defined $parent or croak('missing parent path argument');

   my $_child  = Cwd::Ext::abs_path_nd($child)  or croak("cant normalize child [$child]");
   my $_parent = Cwd::Ext::abs_path_nd($parent) or croak("cant normalize parent [$parent]");

   
   if ($_child eq $_parent){
      warn(" -[$_child] same as [$_parent]");
      return 1;
   }   
   
   # WE DONT WANT /home/hi to match on /home/hithere 
   unless( $_child=~/^$_parent\// ){
      warn (" -[$_child] is not a child of [$_parent]");
      return 0;
   }
   return $_child;
}


1;

__END__

=pod

=head1 NAME

Cwd::Ext - extended file path subroutines

=head1 DESCRIPTION

These are some things that feel missing from Cwd. 

Questions like, 
   Is a file inside the hierarchy of another? 
   What is the resolved absolute path of a file, without dereferencing symlinks?

Unlike with Cwd, this module is in baby stage. So it is NOT tweaked for OS2, NT, etc etc.
This is developed under POSIX.

Nothing is imported by default. You must explicitely import..

=head1 SYNOPSIS

   use Cwd::Ext qw(abs_path_is_in_nd abs_path_is_in abs_path_nd);

=head2 abs_path_nd()

Works just like Cwd::abs_path , only it does (n)o (s)ymlink (d)ereference.

=head2 abs_path_is_in()

Arguments are child path in question, parent path to test against.
Returns boolean. 
Croaks if missing arguments.

Is /home/myself/file1.jpg inside the filesystem hierarchy of /home/myself ?

   my $child  = '/home/myself/file1.jpg';
   my $parent = '/home/myself';

   printf "Does [$child] reside in [$parent]? %s\n",
      
      ( Cwd::Ext::abs_path_is_in($child,$parent) ? 'yes' : 'no' );   

If both paths resolve to same place, returns 1 and warns.
(Should this be different?)

=head2 abs_path_is_in_nd()

Same as abs_path_is_within() but does not resolve symlinks.

=head1 CAVEATS

This module is in ALPHA state. Needs feedback.

=head1 TODO

I want this to inherit Cwd. So that cwd(), etc are exported.

=head1 AUTHOR

Leo Charre leocharre at cpan dot org

Thanks to http://perlmonks.org/?node_id=401112 johngg for resolving paths without resolving symlinks.

=cut





