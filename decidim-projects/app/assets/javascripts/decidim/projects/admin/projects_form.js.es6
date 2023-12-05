$(() => {
  const { attachGeocoding } = window.Decidim;

  const $form = $(".project_form_admin");

  if ($form.length > 0) {
    const $projectCreatedInMeeting = $form.find("#project_created_in_meeting");
    const $projectMeeting = $form.find("#project_meeting");

    const toggleDisabledHiddenFields = () => {
      const enabledMeeting = $projectCreatedInMeeting.prop("checked");
      $projectMeeting.find("select").attr("disabled", "disabled");
      $projectMeeting.hide();

      if (enabledMeeting) {
        $projectMeeting.find("select").attr("disabled", !enabledMeeting);
        $projectMeeting.show();
      }
    };

    $projectCreatedInMeeting.on("change", toggleDisabledHiddenFields);
    toggleDisabledHiddenFields();

    const $projectAddress = $form.find("#project_address");
    if ($projectAddress.length !== 0) {
      attachGeocoding($projectAddress);
    }
  }
});
