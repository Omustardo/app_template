use crate::MyAppState;

impl MyAppState {
    pub(crate) fn show_left_panel(&mut self, ui: &mut egui::Ui) {
        ui.label("Left Panel content here");
    }
}