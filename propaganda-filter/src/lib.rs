use log::{info, warn};
use proxy_wasm::traits::*;
use proxy_wasm::types::*;
use serde_json::Value;
use std::collections::HashMap;
use std::env;
use url::form_urlencoded;

#[no_mangle]
pub fn _start() {
    proxy_wasm::set_log_level(LogLevel::Info);
    proxy_wasm::set_root_context(|_| -> Box<dyn RootContext> {
        Box::new(PropagandaRoot {
            config: FilterConfig {
                head_tag_name: "".to_string(),
                head_tag_value: "".to_string(),
            },
        })
    });
}

struct PropagandaFilter {
    context_id: u32,
    config: FilterConfig,
}

struct PropagandaRoot {
    config: FilterConfig,
}

struct FilterConfig {
    head_tag_name: String,
    head_tag_value: String,
}

impl PropagandaFilter {
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

impl HttpContext for PropagandaFilter {
    fn on_http_request_headers(&mut self, _: usize) -> Action {
        let head_tag_key = self.config.head_tag_name.as_str();
        info!("::::head_tag_key={}", head_tag_key);
        if !head_tag_key.is_empty() {
            self.set_http_request_header(head_tag_key, Some(self.config.head_tag_value.as_str()));
        }
        for (name, value) in self.get_query_params() {
            info!("::::P[{}] -> {}: {}", self.context_id, name, value);
        }
        for (name, value) in &self.get_http_request_headers() {
            info!("::::H[{}] -> {}: {}", self.context_id, name, value);
        }
        match self.get_http_request_header(":path") {
            Some(path) if path == "/hello" => {
                let response_vec = vec![("Hello", "World"), ("Powered-By", "proxy-wasm")];
                match env::var("ISTIO_META_APP_CONTAINERS") {
                    Ok(val) => {
                        info!("::::[{}] -> container_name: {}", self.context_id, val);
                        //response_vec.push(("container_name", x.as_str()))
                    }
                    _ => {}
                }
                self.send_http_response(200, response_vec, Some(b"Hello, World!\n"));
                Action::Pause
            }
            _ => Action::Continue,
        }
    }

    fn on_http_response_headers(&mut self, _: usize) -> Action {
        if !self.config.head_tag_name.as_str().is_empty() {
            self.set_http_response_header(
                self.config.head_tag_name.as_str(),
                Some(self.config.head_tag_value.as_str()),
            );
        }
        for (name, value) in &self.get_http_response_headers() {
            info!("::::H[{}] <- {}: {}", self.context_id, name, value);
        }
        Action::Continue
    }

    fn on_log(&mut self) {
        info!("::::[{}] completed.", self.context_id);
    }
}

impl RootContext for PropagandaRoot {
    fn on_configure(&mut self, _plugin_configuration_size: usize) -> bool {
        if self.config.head_tag_name == "" {
            info!("READING CONFIG");
            match self.get_configuration() {
                Some(config_bytes) => {
                    info!("GOT CONFIG");
                    let cfg: Value = serde_json::from_slice(config_bytes.as_slice()).unwrap();
                    self.config.head_tag_name = cfg
                        .get("head_tag_name")
                        .unwrap()
                        .as_str()
                        .unwrap()
                        .to_string();
                    self.config.head_tag_value = cfg
                        .get("head_tag_value")
                        .unwrap()
                        .as_str()
                        .unwrap()
                        .to_string();
                }
                None => {
                    warn!("NO CONFIG");
                }
            }
        }
        true
    }
    fn create_http_context(&self, context_id: u32) -> Option<Box<dyn HttpContext>> {
        info!(
            "::::create_http_context head_tag_name={},head_tag_value={}",
            self.config.head_tag_name, self.config.head_tag_value
        );
        Some(Box::new(PropagandaFilter {
            context_id,
            config: FilterConfig {
                head_tag_name: self.config.head_tag_name.clone(),
                head_tag_value: self.config.head_tag_value.clone(),
            },
        }))
    }
    fn get_type(&self) -> Option<ContextType> {
        Some(ContextType::HttpContext)
    }
}

impl Context for PropagandaFilter {}

impl Context for PropagandaRoot {}
