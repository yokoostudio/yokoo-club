{% set form_container_floating_class = not settings.search_big_desktop ? 'search-container-floating' %}
{% set form_container_padding_md_class = settings.search_big_desktop ? 'pt-md-0 mb-md-0' : 'pt-md-3' %}
{% set form_container_classes = not_padding ? 'py-0 mb-0 ' ~ form_container_floating_class : 'position-relative-md py-4 pb-md-0 px-3 mb-1 ' ~ form_container_padding_md_class %}

{% if search_modal %}
    <a href="#" class="js-modal-close js-fullscreen-modal-close search-btn search-close-btn d-md-none">
    	<svg class="icon-inline icon-lg svg-icon-text icon-flip-horizontal"><use xlink:href="#chevron"/></svg>
    </a>
{% endif %}

{{ component('search/search-form', {form_classes: { 
	form: form_container_classes, 
	input_group: 'm-0', 
	input: form_input_class, 
	submit: form_submit_class, 
	search_suggestions_container: form_suggests_container_class}, 
	placeholder_text: 'Buscar' | translate}) 
}}