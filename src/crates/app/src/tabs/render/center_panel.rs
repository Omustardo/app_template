use crate::MyAppState;

impl MyAppState {
    pub(crate) fn show_center_panel(&mut self, ui: &mut egui::Ui) {
        ui.label(format!("Center Panel content here"));
    }
}