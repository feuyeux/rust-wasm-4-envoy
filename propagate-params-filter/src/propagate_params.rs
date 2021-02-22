use std::collections::HashMap;

use log::info;
use proxy_wasm::traits::*;
use proxy_wasm::types::*;
use url::form_urlencoded;

#[no_mangle]
pub fn _start() {
    proxy_wasm::set_log_level(LogLevel::Info);
    proxy_wasm::set_root_context(|_| -> Box<dyn RootContext> { Box::new(PropagandaParamsRoot {}) });
}

struct PropagandaParamsFilter {
    context_id: u32,
}

struct PropagandaParamsRoot {}

impl PropagandaParamsFilter {
    fn get_query_params(&self) -> HashMap<String, String> {
        let mut params: HashMap<String, String> = HashMap::new();
        let path = self.get_http_request_header(":path").unwrap();
        let path_parts: Vec<_> = path.split("?").collect();
        if path_parts.len() < 2 {
            return params;
        }
        let query = path_parts[1].to_string();
        let encoded = form_urlencoded::parse(query.as_bytes());
        for (k, v) in encoded {
            params.insert(k.to_owned().to_string(), v.to_owned().to_string());
        }
        return params;
    }
}

impl HttpContext for PropagandaParamsFilter {
    // fn on_http_request_body(&mut self, _body_size: usize, _end_of_stream: bool) -> Action {
    fn on_http_request_headers(&mut self, _: usize) -> Action {
        for (name, value) in self.get_query_params() {
            info!("::::P[{}] -> {}: {}", self.context_id, name, value);
        }
        self.clear_http_route_cache();
        Action::Continue
    }
}

impl RootContext for PropagandaParamsRoot {
    fn create_http_context(&self, context_id: u32) -> Option<Box<dyn HttpContext>> {
        Some(Box::new(PropagandaParamsFilter { context_id }))
    }
    fn get_type(&self) -> Option<ContextType> {
        Some(ContextType::HttpContext)
    }
}

impl Context for PropagandaParamsFilter {}

impl Context for PropagandaParamsRoot {}
