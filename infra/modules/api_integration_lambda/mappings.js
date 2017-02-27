{
  "httpMethod": "$context.httpMethod",
  "resourcePath": "$context.resourcePath",
  "headers": {
    #foreach($header in $input.params().header.keySet())
    "$header": "$util.escapeJavaScript($input.params().header.get($header))" #if($foreach.hasNext),#end

    #end
  },
  "params": {
    #foreach($param in $input.params().path.keySet())
    "$param": "$util.escapeJavaScript($input.params().path.get($param))" #if($foreach.hasNext),#end

    #end
  },
  "query": {
    #foreach($queryParam in $input.params().querystring.keySet())
    "$queryParam": "$util.escapeJavaScript($input.params().querystring.get($queryParam))" #if($foreach.hasNext),#end

    #end
  },
  "body" : $input.json('$'),
  "stage": "$context.stage",
  "stageVariables": {
    #foreach($key in $stageVariables.keySet())
    "$key": "$util.escapeJavaScript($stageVariables.get($key))" #if($foreach.hasNext),#end

    #end
  }
}
