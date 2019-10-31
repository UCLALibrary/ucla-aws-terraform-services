[
  {
    "name": "${fargate_definition_name}-cantaloupe",
    "repositoryCredentials": { "credentialsParameter": "${registry_auth_arn}" },
    "memory": ${cantaloupe_memory},
    "image": "${cantaloupe_image_url}",
    "networkMode": "awsvpc",
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
      { "name" : "CANTALOUPE_DELEGATE_SCRIPT_ENABLED", "value" : "${cantaloupe_delegate_enabled}" },
      { "name" : "CANTALOUPE_DELEGATE_SCRIPT_PATHNAME", "value" : "${cantaloupe_delegate_path}" },
      { "name" : "CANTALOUPE_SOURCE_DELEGATE", "value" : "${cantaloupe_source_delegate}" },
      { "name" : "DELEGATE_URL", "value" : "${delegate_url}" },
      { "name" : "CIPHER_TEXT", "value" : "${cipher_text}" },
      { "name" : "CIPHER_KEY", "value" : "${cipher_key}" },
      { "name" : "JAVA_HEAP_SIZE", "value" : "${cantaloupe_heapsize}" }
    ]
  },
  {
    "name": "${fargate_definition_name}-manifeststore",
    "repositoryCredentials": { "credentialsParameter": "${registry_auth_arn}" },
    "memory": ${manifeststore_memory},
    "image": "${manifeststore_image_url}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${manifeststore_listening_port},
        "hostPort": ${manifeststore_listening_port}
      }
    ],
    "environment": [
      { "name" : "HTTP_PORT", "value" : "${manifeststore_listening_port}" },
      { "name" : "MANIFESTSTORE_S3_ACCESS_KEY", "value" : "${manifeststore_s3_access_key}" },
      { "name" : "MANIFESTSTORE_S3_BUCKET", "value" : "${manifeststore_s3_bucket}" },
      { "name" : "MANIFESTSTORE_S3_REGION", "value" : "${manifeststore_s3_region}" },
      { "name" : "MANIFESTSTORE_S3_SECRET_KEY", "value" : "${manifeststore_s3_secret_key}" }
    ]
  }
]

