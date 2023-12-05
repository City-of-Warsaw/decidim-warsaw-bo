$(() => {
  const $content = $(".picker-content"),
      pickerMore = $content.data("picker-more"),
      pickerPath = $content.data("picker-path"),
      toggleNoProjects = () => {
        const showNoProjects = $("#projects_list li:visible").length === 0
        $("#no_projects").toggle(showNoProjects)
      }

  let jqxhr = null

  toggleNoProjects()

  $(".data_picker-modal-content").on("change keyup", "#projects_filter", (event) => {
    const filter = event.target.value.toLowerCase()

    if (pickerMore) {
      if (jqxhr !== null) {
        jqxhr.abort()
      }

      $content.html("<div class='loading-spinner'></div>")
      jqxhr = $.get(`${pickerPath}?q=${filter}`, (data) => {
        $content.html(data)
        jqxhr = null
        toggleNoProjects()
      })
    } else {
      $("#projects_list li").each((index, li) => {
        $(li).toggle(li.textContent.toLowerCase().indexOf(filter) > -1)
      })
      toggleNoProjects()
    }
  })
})
