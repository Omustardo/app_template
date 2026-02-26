use crate::MyAppState;

impl MyAppState {
    pub(crate) fn show_right_panel(&mut self, ui: &mut egui::Ui) {
        ui.label("Right Panel content here");
    }
}