#!/usr/bin/perl
use    File::Copy qw/cp mv/;

die "missing input arguments\n" if ($#ARGV!=1);
my $pdb = shift;
my $run = shift;
my $directory = shift;
#$pdb =~ tr/[A-Z]/[a-z]/;
#$bm =~ tr/[A-Z]/[a-z]/;

die "all done" if ($run >100);

$path = "/home/ljulio";

make_submit ($pdb, $run, $directory);

print "sending $pdb with status $run.";

#`/usr/local/bin/mnsubmit $path/$pdb.submit_md.cmd 2>/dev/null` =~ /The job \"(.+)\" has been submitted/ ;
$jobname = $1;
sleep 1;
##
##s30c1b01-gigabit1.496.0  ub79617     5/5  18:19 NQ 50  small
##
#my $status = substr (`/usr/local/bin/mnq  | grep STATE`,48,2);
print "..job $jobname gone with queue_status \n";

exit(0);

#####################################################################################
##                              Subrutines                                          #
#####################################################################################

sub make_submit {
my $pdb = shift;
my $run = shift;
my $directory = shift;
my $last = $run -1;
my $next = $run +1;
my $dir = $pdb;
$dir =~ tr/[a-z]/[A-Z]/;
open (OUT, ">$path/$directory/$pdb.md_$run.sh");
print OUT "#!/bin/bash
#SBATCH --job-name=\"$pdb\"
#SBATCH --nodes=1
#SBATCH --workdir=$path/$directory
#SBATCH --error=\"md-%j.err\"
#SBATCH --output=\"md-%j.out\"
#SBATCH --gres=gpu:1
#SBATCH --partition=freeriders
#SBATCH --time=24:00:00

echo \"trabajo \\\"\${SLURM_JOB_NAME}\\\"\"
echo \"    id: \${SLURM_JOB_ID}\"
echo \"    partición: \${SLURM_JOB_PARTITION}\"
echo \"    nodos: \${SLURM_JOB_NODELIST}\"
date +\"inicio %d.%m.%Y - %T\"

echo \"
--------------------------------------------------------------------------------
\"

# INICIO VARIABLES IMPORTANTES
#
# NO TOCAR. No se aceptaron reclamos en caso de modificar estas líneas. Deberán
# incluirlas siempre, hasta próximo aviso.
#
[ -r /etc/profile ] && . /etc/profile
#
# FIN VARIABLES IMPORTANTES

# El programa se encuentra en `/home/alguien/ejemplos/pi/pi`. Como más arriba
# seteé el directorio de trabajo a `/home/alguien/ejemplos/pi`, solo basta
# poner el ejecutable sin ninguna ruta adicional.


nohup  /usr/bin/perl $path/send.md.pl $pdb $next $directory

sbatch $pdb.md_$next.sh

echo \"
--------------------------------------------------------------------------------
\"

date +\"fin %d.%m.%Y - %T\"
\n";

close OUT;
}

exit(0);
