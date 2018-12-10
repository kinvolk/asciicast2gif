#!/bin/bash

# Usage:
# ./scripts/asciinema.sh topic

log2asciinema() {
  echo '{"version": 2, "width": 80, "height": 25, "timestamp": 1600000000, "env": {"SHELL": "/bin/bash", "TERM": "xterm-256color"}}'
  COUNTER=0.00
  while IFS= read -r LINE ; do
    if [[ "$LINE" =~ [a-z]*@[a-z]*\ [a-z]*]\$\  ]]; then
      COUNTER=$(printf '%.2f' "$(bc <<<"scale=2;$COUNTER+0.04")")
      echo '['$COUNTER', "o", "$ "]'
      COUNTER=$(printf '%.2f' "$(bc <<<"scale=2;$COUNTER+0.96")")
      while IFS= read -r -N 1 CHAR ; do
        COUNTER=$(printf '%.2f' "$(bc <<<"scale=2;$COUNTER+0.04")")
        echo '['$COUNTER', "o", "'$(sed 's/"/\\"/g' <<<"$CHAR")'"]'
      done < <(sed 's/^\[[a-z]*@[a-z]* [a-z]*\]\$ //' <<<"$LINE")
      COUNTER=$(printf '%.2f' "$(bc <<<"scale=2;$COUNTER+1.00")")
      echo '['$COUNTER', "o", "\r\n"]'
    else
      COUNTER=$(printf '%.2f' "$(bc <<<"scale=2;$COUNTER+0.04")")
      echo '['$COUNTER', "o", "'$(sed 's/"/\\"/g' <<<"$LINE")'\r\n"]'
    fi
  done
}

asciinema2gif() {
	SRC=$1
	DST=$2

	SRC_DIR=$(realpath $(dirname $SRC))
	SRC_FILE=$(basename $SRC)
	DST_DIR=$(realpath $(dirname $DST))
	DST_FILE=$(basename $DST)
	sudo docker run --rm -v ${SRC_DIR}:/data -v ${DST_DIR}:/out asciinema/asciicast2gif /data/${SRC_FILE} /out/$DST_FILE
	sudo chown $UID:$UID ${DST}
}

cat $1.txt | log2asciinema > $1.asciinema
asciinema2gif $1.asciinema $1.gif
rm -f $1.asciinema
