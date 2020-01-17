[
  {
    "name": "${fargate_definition_name}-cantaloupe",
    "repositoryCredentials": { "credentialsParameter": "${registry_auth_arn}" },
    "memory": ${cantaloupe_memory},
    "image": "${cantaloupe_image_url}",
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${cantaloupe_cloudwatch_log_group}",
            "awslogs-region": "${cantaloupe_cloudwatch_region}",
            "awslogs-stream-prefix": "${cantaloupe_cloudwatch_stream_prefix}"
         }
    },
    "portMappings": [
      {
        "containerPort": ${cantaloupe_listening_port},
        "hostPort": ${cantaloupe_listening_port}
      }
    ],
    "environment": [
      { "name" : "CANTALOUPE_ENDPOINT_ADMIN_ENABLED", "value" : "${cantaloupe_enable_admin}" },
      { "name" : "CANTALOUPE_ENDPOINT_ADMIN_SECRET", "value" :  "${cantaloupe_admin_secret}" },
      { "name" : "CANTALOUPE_CACHE_SERVER_DERIVATIVE_ENABLED", "value" : "${cantaloupe_enable_cache_server}" },
      { "name" : "CANTALOUPE_CACHE_SERVER_DERIVATIVE", "value" : "${cantaloupe_cache_server_derivative}" },
      { "name" : "CANTALOUPE_CACHE_SERVER_DERIVATIVE_TTL_SECONDS", "value" : "${cantaloupe_cache_server_derivative_ttl}" },
      { "name" : "CANTALOUPE_CACHE_SERVER_PURGE_MISSING", "value" : "${cantaloupe_cache_server_purge_missing}" },
      { "name" : "CANTALOUPE_PROCESSOR_SELECTION_STRATEGY", "value" : "${cantaloupe_processor_selection_strategy}" },
      { "name" : "CANTALOUPE_MANUAL_PROCESSOR_JP2", "value" : "${cantaloupe_manual_processor_jp2}" },
      { "name" : "CANTALOUPE_S3CACHE_ACCESS_KEY_ID", "value" : "${cantaloupe_s3_cache_access_key}" },
      { "name" : "CANTALOUPE_S3CACHE_SECRET_KEY", "value" : "${cantaloupe_s3_cache_secret_key}" },
      { "name" : "CANTALOUPE_S3CACHE_ENDPOINT", "value" : "${cantaloupe_s3_cache_endpoint}" },
      { "name" : "CANTALOUPE_S3CACHE_BUCKET_NAME", "value" : "${cantaloupe_s3_cache_bucket}" },
      { "name" : "CANTALOUPE_S3SOURCE_ACCESS_KEY_ID", "value" : "${cantaloupe_s3_source_access_key}" },
      { "name" : "CANTALOUPE_S3SOURCE_SECRET_KEY", "value" : "${cantaloupe_s3_source_secret_key}" },
      { "name" : "CANTALOUPE_S3SOURCE_ENDPOINT", "value" : "${cantaloupe_s3_source_endpoint}" },
      { "name" : "CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_BUCKET_NAME", "value" : "${cantaloupe_s3_source_bucket}" },
      { "name" : "CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_PATH_SUFFIX", "value" : "${cantaloupe_s3_source_basiclookup_suffix}" },
      { "name" : "CANTALOUPE_SOURCE_STATIC", "value" : "${cantaloupe_source_static}" },
      { "name" : "JAVA_HEAP_SIZE", "value" : "${cantaloupe_heapsize}" }
    ]
  },
  {
    "name": "${fargate_definition_name}-fester",
    "repositoryCredentials": { "credentialsParameter": "${registry_auth_arn}" },
    "memory": ${fester_memory},
    "image": "${fester_image_url}",
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${fester_cloudwatch_log_group}",
            "awslogs-region": "${fester_cloudwatch_region}",
            "awslogs-stream-prefix": "${fester_cloudwatch_stream_prefix}"
         }
    },
    "portMappings": [
      {
        "containerPort": ${fester_listening_port},
        "hostPort": ${fester_listening_port}
      }
    ],
    "environment": [
      { "name" : "FESTER_HTTP_PORT", "value" : "${fester_listening_port}" },
      { "name" : "FESTER_S3_ACCESS_KEY", "value" : "${fester_s3_access_key}" },
      { "name" : "FESTER_S3_BUCKET", "value" : "${fester_s3_bucket}" },
      { "name" : "FESTER_S3_REGION", "value" : "${fester_s3_region}" },
      { "name" : "FESTER_S3_SECRET_KEY", "value" : "${fester_s3_secret_key}" },
      { "name" : "IIIF_BASE_URL", "value" : "${fester_iiif_base_url}" }
    ]
  }
]

