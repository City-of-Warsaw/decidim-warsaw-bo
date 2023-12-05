$(() => {
  const $form = $(".form.newsletter_deliver");

  if ($form.length > 0) {
    const $sendNewsletterToAllUsers = $form.find("#send_newsletter_to_all_users");
    const $sendNewsletterToFollowers = $form.find("#send_newsletter_to_followers");
    const $sendNewsletterToParticipants = $form.find("#send_newsletter_to_participants");
    const $participatorySpacesForSelect = $form.find("#participatory_spaces_for_select");
    const $newsletter_send_to_file = $form.find("#newsletter_send_to_file");
    const $newsletter_send_to_authors = $form.find("#newsletter_send_to_authors");
    const $send_newsletter_to_coauthors = $form.find("#send_newsletter_to_coauthors");
    const $newsletter_send_to_all_users = $form.find("#newsletter_send_to_all_users");
    const $newsletter_send_to_coauthors = $form.find("#newsletter_send_to_coauthors");
    const $newsletter_send_users_with_agreement_of_evaluation = $form.find("#newsletter_send_users_with_agreement_of_evaluation");
    const $file_input = $form.find("#file_input");
    const $project_status = $form.find("#project_status");


    const $newsletter_internal_user_roles_koord = $form.find("#newsletter_internal_user_roles_koord");
    const $newsletter_internal_user_roles_podkoord = $form.find("#newsletter_internal_user_roles_podkoord");
    const $newsletter_internal_user_roles_weryf = $form.find("#newsletter_internal_user_roles_weryf");
    const $newsletter_internal_user_roles_edytor = $form.find("#newsletter_internal_user_roles_edytor");

    $newsletter_internal_user_roles_koord.on("change", (event) => {
      const checked = event.target.checked;
      if (checked) {
        $participatorySpacesForSelect.hide();
        $newsletter_send_to_authors.prop("checked", false);
        $newsletter_internal_user_roles_podkoord.prop("checked", false);
        $newsletter_internal_user_roles_weryf.prop("checked", false);
        $newsletter_internal_user_roles_edytor.prop("checked", false);
        $newsletter_send_to_all_users.prop("checked", false);
        $newsletter_send_to_coauthors.prop("checked", false);
        $newsletter_send_to_file.prop("checked", false);
        $newsletter_send_users_with_agreement_of_evaluation.prop("checked", false);
        $project_status.find("input[type='checkbox']").prop("checked", false);
        $project_status.hide();
        $file_input.hide();
      }
    });

    $newsletter_internal_user_roles_podkoord.on("change", (event) => {
      const checked = event.target.checked;
      if (checked) {
        $participatorySpacesForSelect.hide();
        $newsletter_send_to_authors.prop("checked", false);
        $newsletter_internal_user_roles_koord.prop("checked", false);
        $newsletter_internal_user_roles_weryf.prop("checked", false);
        $newsletter_send_to_all_users.prop("checked", false);
        $newsletter_internal_user_roles_edytor.prop("checked", false);
        $newsletter_send_to_coauthors.prop("checked", false);
        $newsletter_send_to_file.prop("checked", false);
        $newsletter_send_users_with_agreement_of_evaluation.prop("checked", false);
        $project_status.find("input[type='checkbox']").prop("checked", false);
        $project_status.hide();
        $file_input.hide();
      }
    });
    $newsletter_internal_user_roles_weryf.on("change", (event) => {
      const checked = event.target.checked;
      if (checked) {
        $participatorySpacesForSelect.hide();
        $newsletter_send_to_authors.prop("checked", false);
        $newsletter_send_to_all_users.prop("checked", false);
        $newsletter_internal_user_roles_koord.prop("checked", false);
        $newsletter_internal_user_roles_podkoord.prop("checked", false);
        $newsletter_internal_user_roles_edytor.prop("checked", false);
        $newsletter_send_to_coauthors.prop("checked", false);
        $newsletter_send_to_file.prop("checked", false);
        $newsletter_send_users_with_agreement_of_evaluation.prop("checked", false);
        $project_status.find("input[type='checkbox']").prop("checked", false);
        $project_status.hide();
        $file_input.hide();
      }
    });

    $newsletter_internal_user_roles_edytor.on("change", (event) => {
      const checked = event.target.checked;
      if (checked) {
        $participatorySpacesForSelect.hide();
        $newsletter_send_to_authors.prop("checked", false);
        $newsletter_send_to_all_users.prop("checked", false);
        $newsletter_internal_user_roles_koord.prop("checked", false);
        $newsletter_internal_user_roles_podkoord.prop("checked", false);
        $newsletter_internal_user_roles_weryf.prop("checked", false);
        $newsletter_send_to_coauthors.prop("checked", false);
        $newsletter_send_to_file.prop("checked", false);
        $newsletter_send_users_with_agreement_of_evaluation.prop("checked", false);
        $project_status.find("input[type='checkbox']").prop("checked", false);
        $project_status.hide();
        $file_input.hide();
      }
    });

    $file_input.hide();
    $project_status.hide();
    $participatorySpacesForSelect.hide();

    const areCheckboxesUnchecked = () => !($newsletter_send_to_all_users.is(":checked") || $newsletter_send_users_with_agreement_of_evaluation.is(":checked") || $newsletter_send_to_authors.is(":checked") || $newsletter_send_to_coauthors.is(":checked"));

    $sendNewsletterToAllUsers.on("change", (event) => {
      const checked = event.target.checked;
      if (checked) {
        $participatorySpacesForSelect.hide();
        $newsletter_send_to_authors.prop("checked", false);
        $newsletter_send_to_coauthors.prop("checked", false);
        $newsletter_send_to_file.prop("checked", false);
        $newsletter_internal_user_roles_koord.prop("checked", false);
        $newsletter_internal_user_roles_podkoord.prop("checked", false);
        $newsletter_internal_user_roles_weryf.prop("checked", false);
        $newsletter_internal_user_roles_edytor.prop("checked", false);
        $newsletter_send_users_with_agreement_of_evaluation.prop("checked", false);
        $project_status.find("input[type='checkbox']").prop("checked", false);
        $project_status.hide();
        $file_input.hide();
      } else if (areCheckboxesUnchecked()) $newsletter_send_to_all_users.prop("checked", true);
    })

    $newsletter_send_users_with_agreement_of_evaluation.on("change", (event) => {
      const checked = event.target.checked;
      if (checked) {
        $participatorySpacesForSelect.hide();
        $newsletter_send_to_authors.prop("checked", false);
        $newsletter_send_to_coauthors.prop("checked", false);
        $newsletter_send_to_all_users.prop("checked", false);
        $newsletter_send_to_file.prop("checked", false);
        $newsletter_internal_user_roles_koord.prop("checked", false);
        $newsletter_internal_user_roles_podkoord.prop("checked", false);
        $newsletter_internal_user_roles_weryf.prop("checked", false);
        $newsletter_internal_user_roles_edytor.prop("checked", false);
        $project_status.find("input[type='checkbox']").prop("checked", false);
        $project_status.hide();
        $file_input.hide();
      } else if (areCheckboxesUnchecked()) $newsletter_send_to_all_users.prop("checked", true);
    })

    $newsletter_send_to_file.on("change", (event) => {
      const checked = event.target.checked;
      if (checked) {
        $participatorySpacesForSelect.find("select option").prop("selected", false);
        $participatorySpacesForSelect.hide();
        $project_status.find("input[type='checkbox']").prop("checked", false);
        $project_status.hide();
        $file_input.show();
        $newsletter_send_to_authors.prop("checked", false);
        $newsletter_send_to_all_users.prop("checked", false);
      } else {
        $sendNewsletterToFollowers.find("input[type='checkbox']").prop("checked", !checked);
        $project_status.find("input[type='checkbox']").prop("checked", false);
        $sendNewsletterToParticipants.find("input[type='checkbox']").prop("checked", !checked);
        $file_input.hide();
      }
    })

    $newsletter_send_to_authors.on("change", (event) => {
      const checked = event.target.checked;
      if (checked) {
        $participatorySpacesForSelect.show();
        $project_status.show();
        $file_input.hide();
        $newsletter_send_to_file.prop("checked", false);
        $newsletter_send_to_all_users.prop("checked", false);
        $newsletter_send_users_with_agreement_of_evaluation.prop("checked", false);
        $newsletter_internal_user_roles_koord.prop("checked", false);
        $newsletter_internal_user_roles_podkoord.prop("checked", false);
        $newsletter_internal_user_roles_weryf.prop("checked", false);
        $newsletter_internal_user_roles_edytor.prop("checked", false);
      } else {
        if ($newsletter_send_to_coauthors.is(":checked")) return false; 
        $participatorySpacesForSelect.find("select option").prop("selected", false);
        $participatorySpacesForSelect.hide();
        $project_status.find("input[type='checkbox']").prop("checked", false);
        $project_status.hide();
        $file_input.hide();

        if (areCheckboxesUnchecked()) $newsletter_send_to_all_users.prop("checked", true);
      }
    })

    $newsletter_send_to_coauthors.on("change", (event) => {
      const checked = event.target.checked;
      if (checked) {
        $participatorySpacesForSelect.show();
        $project_status.show();
        $file_input.hide();
        $newsletter_send_to_file.prop("checked", false);
        $newsletter_send_to_all_users.prop("checked", false);
        $newsletter_send_users_with_agreement_of_evaluation.prop("checked", false);
        $newsletter_internal_user_roles_koord.prop("checked", false);
        $newsletter_internal_user_roles_podkoord.prop("checked", false);
        $newsletter_internal_user_roles_weryf.prop("checked", false);
        $newsletter_internal_user_roles_edytor.prop("checked", false);
      } else {
        if ($newsletter_send_to_authors.is(":checked")) return false; 
        $participatorySpacesForSelect.find("select option").prop("selected", false);
        $participatorySpacesForSelect.hide();
        $project_status.find("input[type='checkbox']").prop("checked", false);
        $project_status.hide();
        $file_input.hide();

        if (areCheckboxesUnchecked()) $newsletter_send_to_all_users.prop("checked", true);
      }
    })

    // $sendNewsletterToFollowers.on("change", (event) => {
    //   const checked = event.target.checked;
    //   const selectiveNewsletterParticipants = $sendNewsletterToParticipants.find("input[type='checkbox']").prop("checked");
    //
    //   if (checked) {
    //     $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", !checked);
    //     $participatorySpacesForSelect.show();
    //   } else if (!selectiveNewsletterParticipants) {
    //     $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", true);
    //     $participatorySpacesForSelect.hide();
    //   }
    // })
    //
    // $sendNewsletterToParticipants.on("change", (event) => {
    //   const checked = event.target.checked;
    //   const selectiveNewsletterFollowers = $sendNewsletterToFollowers.find("input[type='checkbox']").prop("checked");
    //   if (checked) {
    //     $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", !checked);
    //     $participatorySpacesForSelect.show();
    //   } else if (!selectiveNewsletterFollowers) {
    //     $sendNewsletterToAllUsers.find("input[type='checkbox']").prop("checked", true);
    //     $participatorySpacesForSelect.hide();
    //   }
    // })
    //
    // if (checkSelectiveNewsletterFollowers || checkSelectiveNewsletterParticipants) {
    //   $participatorySpacesForSelect.show();
    // } else {
    //   $participatorySpacesForSelect.hide();
    // }

    $(".form .spaces-block-tag").each(function(_i, blockTag) {
      const selectTag = $(blockTag).find(".chosen-select")
      selectTag.change(function() {
        let optionSelected = selectTag.find("option:selected").val()
        if (optionSelected === "all") {
          selectTag.find("option").not(":first").prop("selected", true);
          selectTag.find("option[value='all']").prop("selected", false);
        } else if (optionSelected === "") {
          selectTag.find("option").not(":first").prop("selected", false);
        }
      });
    })

    function updateRecipientsCount() {
      let $data = $form.serializeJSON().newsletter;
      let $url = $form.data("recipients-count-newsletter-path");
      const $modal = $("#recipients_count_spinner");
      $modal.removeClass("hide");
      $.get($url, {data: $data}, function(recipientsCount) {
        $("#recipients_count").text(recipientsCount);
      }).always(function() {
        $modal.addClass("hide");
      });
    }

    $form.on("change", updateRecipientsCount);

    updateRecipientsCount();
  }
});
