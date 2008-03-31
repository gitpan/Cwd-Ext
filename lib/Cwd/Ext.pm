package Cwd::Ext;
use strict;
use Exporter;
use Carp;
use vars qw(@ISA @EXPORT_OK $VERSION @EXPORT $VERSION $DEBUG %EXPORT_TAGS);
@ISA = qw/Exporter/;
@EXPORT_OK = qw(abs_path_is_in abs_path_is_in_nd abs_path_nd abs_path_matches_into symlinks_supported);
%EXPORT_TAGS = ( all => \@EXPORT_OK );
$VERSION = sprintf "%d.%02d", q$Revision: 1.5 $ =~ /(\d+)/g;


sub abs_path_nd {   
   my $abs_path = shift;
   return $abs_path if $abs_path=~m{^/$};
   
   unless( $abs_path=~/^\// ){
      require Cwd;
      $abs_path = Cwd::cwd()."/$abs_path";
   }
    
    my @elems = split m{/}, $abs_path;
    my $ptr = 1;
    while($ptr <= $#elems){
        if($elems[$ptr] eq ''      ){
            splice @elems, $ptr, 1;
        }

        elsif($elems[$ptr] eq '.'  ){
            splice @elems, $ptr, 1;
        }

        elsif($elems[$ptr] eq '..' ){
            if($ptr < 2){
                splice @elems, $ptr, 1;
            }
            else {
                $ptr--;
                splice @elems, $ptr, 2;
            }
        }
        else {
            $ptr++;
        }
    }

    return $#elems ? join q{/}, @elems : q{/};
}


sub abs_path_matches_into {
   my($child,$parent)=@_;
   defined $child  or die('missing child');
   defined $parent or die('missing parent');
   
   if($child eq $parent){
      warn(" - args are the same, returning true") if $DEBUG;
      return $child;
   }

   # WE DON'T WANT /home/hi to match on /home/hithere 
   unless( $child=~/^$parent\// ){
      warn (" -[$child] is not a child of [$parent]") if $DEBUG;
      return 0;
   }
   return $child;
}  

sub abs_path_is_in {
   my($child,$parent) = @_;
   defined $child  or confess('missing child path argument');
   defined $parent or confess('missing parent path argument');
   
   require Cwd;
   my $_child  = Cwd::abs_path($child)  or warn("cant normalize child [$child]") and return;
   my $_parent = Cwd::abs_path($parent) or warn("cant normalize parent [$parent]") and return;

   return abs_path_matches_into($_child,$_parent);
}


sub abs_path_is_in_nd {
   my($child,$parent) = @_;
   defined $child  or confess('missing child path argument');
   defined $parent or confess('missing parent path argument');

   my $_child  = Cwd::Ext::abs_path_nd($child)  or warn("cant normalize child [$child]") and return;
   my $_parent = Cwd::Ext::abs_path_nd($parent) or warn("cant normalize parent [$parent]") and return;

   return abs_path_matches_into($_child,$_parent);
}


sub symlinks_supported {
   return eval { symlink("",""); 1 }
}

1;

__END__

=pod

=head1 NAME

Cwd::Ext - no symlink dereference

=head1 SYNOPSIS

Let's imagine that '/home/myself/stuff/music' is a soft link to '/home/myself/documents/music', and our
current working directory is '/home/myself'..

   use Cwd::Ext ':all';
   
   abs_path_nd('./stuff/music'); # returns /home/myself/stuff/music

   abs_path_is_in_nd( '/home/myself/stuff/music', '/home/myself/stuff' ); # returns true, /home/myself/stuff/music



=head1 DESCRIPTION

These are some things that feel missing from Cwd. 

Questions like, 
   Is a file inside the hierarchy of another? 
   What is the resolved absolute path of a file, without dereferencing symlinks?

Unlike with Cwd, this module is in baby stage. So it is NOT tweaked for OS2, NT, etc etc.
This is developed under POSIX.

This module does not export by default. You must explicitely import what you want to use.

=head1 SUBS

=head2 abs_path_nd()

Works just like Cwd::abs_path , only it does (n)o symlink (d)ereference.

=head2 abs_path_is_in()

Arguments are child path in question, parent path to test against.
Returns resolved abs path of child if yes, false if no.

Will confess if missing arguments.
If either path can't be resolved, warns and returns undef.

Is /home/myself/file1.jpg inside the filesystem hierarchy of /home/myself ?

   my $child  = '/home/myself/file1.jpg';
   my $parent = '/home/myself';

   printf "Does [$child] reside in [$parent]? %s\n",
      
      ( Cwd::Ext::abs_path_is_in($child,$parent) ? 'yes' : 'no' );   

If both paths resolve to same place, returns 1 and warns.
(Should this be different?)

=head2 abs_path_is_in_nd()

Same as abs_path_is_within() but does not resolve symlinks.

=head2 abs_path_matches_into()

Arg is child abs path, and parent abs path.
Does not use Cwd to resolve anything, this
just performs a substring match, returns boolean

=head2 symlinks_supported()

Does an eval to check if this machine supports symlinks.

=head1 CAVEATS

This module is in ALPHA state. Needs feedback.

=head1 TODO

I want this to inherit Cwd. So that cwd(), etc are exported. Currently, you have to use Cwd and Cwd::Ext to
access both these subs and Cwd subs.

=head1 SEE ALSO

L<Cwd>

=head1 AUTHOR

Leo Charre leocharre at cpan dot org

Thanks to http://perlmonks.org/?node_id=401112 johngg for resolving paths without resolving symlinks.

=cut





