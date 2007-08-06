use ExtUtils::MakeMaker;
WriteMakefile(
   NAME => 'Cwd::Ext',
   VERSION_FROM => 'lib/Cwd/Ext.pm',
   PREREQ_PM => {
      Cwd => 0,
      Carp => 0,
   } 
);
