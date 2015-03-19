#!/usr/bin/env bash

TOOLS=$(find bin -type f | awk '{gsub(".dart", "");gsub("bin/", "");print}')

[ -d scripts ] && rm -rf scripts
mkdir scripts

for TOOL in ${TOOLS}
do
  S=$(pwd)/bin/${TOOL}.dart
  F=scripts/${TOOL}
  echo -e "#!/usr/bin/env bash\ndart ${S} \${@}" > ${F}
  chmod +x ${F}
done
