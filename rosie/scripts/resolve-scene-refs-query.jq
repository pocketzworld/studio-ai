[path(.. | objects | select(.objectProperties?.name? as $n | $names | index($n) != null)) as $p |
 getpath($p) as $obj |
 {
   referenceId: $obj.referenceId,
   name: $obj.objectProperties.name,
   jqPath: ($p | map(if type == "number" then "[\(.)]\("")" else ".\(.)" end) | join(""))
 }]
