# Mappingbased Extraction Config


### Cronjob

```
0 0 7 * * /bin/bash -c '/home/extractor/marvin-config/mappings/mappings-release.sh' >/dev/null 2>&1
```