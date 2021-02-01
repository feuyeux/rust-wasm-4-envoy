use log::info;
use proxy_wasm::traits::*;
use proxy_wasm::types::*;

#[no_mangle]
pub fn _start() {
    proxy_wasm::set_log_level(LogLevel::Info);
    proxy_wasm::set_root_context(|_| -> Box<dyn RootContext> { Box::new(WatermarkRoot {}) });
}

struct WatermarkFilter {
    context_id: u32,
}

struct WatermarkRoot {}

impl HttpContext for WatermarkFilter {
    fn on_http_response_headers(&mut self, _: usize) -> Action {
        // If there is a Content-Length header and we change the length of
        // the body later, then clients will break. So remove it.
        // We must do this here, because once we exit this function we
        // can no longer modify the response headers.
        self.set_http_response_header("content-length", None);
        Action::Continue
    }

    fn on_http_response_body(&mut self, body_size: usize, end_of_stream: bool) -> Action {
        if !end_of_stream {
            // Wait -- we'll be called again when the complete body is buffered
            // at the host side.
            return Action::Pause;
        }
        if let Some(body_bytes) = self.get_http_response_body(0, body_size) {
            let watermark = "wasm";
            let mut body_str = String::from_utf8(body_bytes).unwrap();
            if body_str.ends_with('\n') {
                body_str.pop();
                if body_str.ends_with('\r') {
                    body_str.pop();
                }
            }
            let new_body = format!("{}@{}", body_str, watermark);
            info!(
                "::::[{}] new_body:{},usize:{}",
                self.context_id,
                &new_body,
                new_body.capacity()
            );
            self.set_http_response_body(0, new_body.capacity(), &new_body.into_bytes());
        }
        Action::Continue
    }
    fn on_log(&mut self) {
        info!("::::[{}] completed.", self.context_id);
    }
}

impl RootContext for WatermarkRoot {
    fn create_http_context(&self, context_id: u32) -> Option<Box<dyn HttpContext>> {
        Some(Box::new(WatermarkFilter { context_id }))
    }
    fn get_type(&self) -> Option<ContextType> {
        Some(ContextType::HttpContext)
    }
}

impl Context for WatermarkFilter {}

impl Context for WatermarkRoot {}
