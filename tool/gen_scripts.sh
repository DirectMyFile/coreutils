#!/usr/bin/env bash

source $(dirname ${0})/gen_snapshots.sh

[ -d scripts ] && rm -rf scripts
mkdir scripts

for TOOL in ${TOOLS}
do
  S=$(pwd)/snapshots/${TOOL}.snapshot
  F=scripts/${TOOL}
  echo -e "#!/usr/bin/env bash\ndart ${S}" > ${F}
  chmod +x ${F}
done
