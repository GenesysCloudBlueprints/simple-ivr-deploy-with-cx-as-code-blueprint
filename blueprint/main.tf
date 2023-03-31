terraform {
   backend "pg" {
    conn_str = "postgres://postgres:tfbackend123@localhost/terraform_backend?sslmode=disable"
  }
  required_providers {
    genesyscloud = {
      source = "mypurecloud/genesyscloud"
    }
  }
}

resource "genesyscloud_user" "sf_johnsmith" {
  email           = "john.r.smith@simplefinancial.com"
  name            = "John R Smith"
  password        = "b@Zinga1972"
  state           = "active"
  department      = "IRA"
  title           = "Agent"
  acd_auto_answer = true
  addresses {

    phone_numbers {
      number     = "9205551212"
      media_type = "PHONE"
      type       = "MOBILE"
    }
  }
  employer_info {
    official_name = "John R Smith"
    employee_id   = "12345"
    employee_type = "Full-time"
    date_hire     = "2021-03-18"
  }
}

resource "genesyscloud_user" "sf_janesmith" {
  email           = "jane.s.smith@simplefinancial.com"
  name            = "Jane S. Smith"
  password        = "b@Zinga1972"
  state           = "active"
  department      = "IRA"
  title           = "Agent"
  acd_auto_answer = true
  addresses {

    phone_numbers {
      number     = "9205551212"
      media_type = "PHONE"
      type       = "MOBILE"
    }
  }
  employer_info {
    official_name = "John Smith"
    employee_id   = "12345"
    employee_type = "Full-time"
    date_hire     = "2021-03-18"
  }
}

resource "genesyscloud_routing_queue" "queue_ira" {
  name                     = "Simple Financial IRA queue"
  description              = "Simple Financial IRA questions and answers"
  acw_wrapup_prompt        = "MANDATORY_TIMEOUT"
  acw_timeout_ms           = 300000
  skill_evaluation_method  = "BEST"
  auto_answer_only         = true
  enable_transcription     = true
  enable_manual_assignment = true

  members {
    user_id  = genesyscloud_user.sf_johnsmith.id
    ring_num = 1
  }
}

resource "genesyscloud_routing_queue" "queue_K401" {
  name                     = "Simple Financial 401K queue"
  description              = "Simple Financial 401K questions and answers"
  acw_wrapup_prompt        = "MANDATORY_TIMEOUT"
  acw_timeout_ms           = 300001
  skill_evaluation_method  = "BEST"
  auto_answer_only         = true
  enable_transcription     = true
  enable_manual_assignment = true
  members {
    user_id  = genesyscloud_user.sf_johnsmith.id
    ring_num = 1
  }

  members {
    user_id  = genesyscloud_user.sf_janesmith.id
    ring_num = 1
  }
}


###
#  Archy Work
###
resource "genesyscloud_flow" "deploy_archy_flow" {
  depends_on = [
    genesyscloud_routing_queue.queue_K401,
    genesyscloud_routing_queue.queue_ira
  ]

    filepath          = "./SimpleFinancialIvr_v2-0.yaml"
    file_content_hash = filesha256("./SimpleFinancialIvr_v2-0.yaml")     
}

resource "genesyscloud_telephony_providers_edges_did_pool" "mygcv_number" {
  start_phone_number = "+19205422729"
  end_phone_number   = "+19205422729"
  description        = "GCV Number for inbound calls this is a test demo"
  comments           = "Additional comments"
  depends_on = [
    genesyscloud_flow.deploy_archy_flow
  ]
}

resource "genesyscloud_architect_ivr" "mysimple_ivr" {
  name               = "A simple IVR"
  description        = "A sample IVR configuration is created"
  dnis               = ["+19205422729", "+19205422729"]
  open_hours_flow_id = genesyscloud_flow.deploy_archy_flow.id
  depends_on         = [genesyscloud_telephony_providers_edges_did_pool.mygcv_number]
}

