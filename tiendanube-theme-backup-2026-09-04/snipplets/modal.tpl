{# /*============================================================================
  #Modal
==============================================================================*/

#Properties
    // ID
    // Position - Top, Right, Bottom, Left
    // Transition - Slide and Fade
    // Width - Full, Drawer and Box
    // modal_form_action - For modals that has a form
    // modal_fixed_footer - For modals with fixed footer. Need to include the fixed part inside the footer


#Topbar
    // Block - modal_topbar
#Head
    // Block - modal_head
#Body
    // Block - modal_body
#Footer
    // Block - modal_footer

#}

{% set modal_header_title = modal_header_title ?? true %}

<div id="{{ modal_id }}" class="js-modal {% if modal_mobile_full_screen %}js-fullscreen-modal{% endif %} {% if desktop_overlay_only %}js-modal-overlay-md{% endif %} modal modal-{{ modal_class }} modal-{{modal_position}} modal-{{modal_position_desktop}}-md transition-{{modal_transition}} modal-{{modal_width}} transition-soft {% if modal_zindex_top %}modal-zindex-top{% endif %}" style="display: none;" {% if data_component %}data-component="{{ data_component }}"{% endif %} {% if custom_data_attribute %}data-{{ custom_data_attribute }}="{{ custom_data_attribute_value }}"{% endif %} {% if modal_mobile_full_screen %}data-modal-url="{{ modal_url}}"{% endif %}>
    {% if modal_form_action %}
    <form action="{{ modal_form_action }}" method="post" class="{{ modal_form_class }} {% if modal_footer and modal_fixed_footer %}modal-with-fixed-footer{% endif %}" {% if modal_form_hook %}data-store="{{ modal_form_hook }}"{% endif %}>
    {% endif %}
    {% if modal_footer and modal_fixed_footer %}
        <div class="modal-with-fixed-footer">
            <div class="modal-scrollable-area">
    {% endif %}
                <div class="{% if not search_modal %}js-modal-close{% endif %} {% if modal_mobile_full_screen %}js-fullscreen-modal-close{% endif %} {% if modal_zindex_top %}js-close-over-modal{% endif %} modal-header {% if not modal_header_title %}modal-header-no-title modal-close{% endif %} {% if modal_close_floating and not modal_header_title %}modal-close-floating{% endif %} {{ modal_header_class }}">
                    {% if modal_header_title %}
                        <div class="row no-gutters align-items-center">
                            <div class="col {{ modal_title_class }} {% if modal_close_floating %}px-3 pr-md-3 pl-md-5{% else %}pr-3 pl-5{% endif %}">
                                {% block modal_head %}{% endblock %}
                            </div>
                            <div class="col-auto">
                                <a class="js-modal-close modal-close {% if modal_close_floating %}modal-close-floating{% endif %} pr-md-0 {{ modal_close_class }}">
                                    <svg class="icon-inline svg-icon-text"><use xlink:href="#times"/></svg>
                                </a>
                            </div>
                        </div>
                    {% else %}
                        <svg class="icon-inline svg-icon-text"><use xlink:href="#times"/></svg>
                    {% endif %}
                </div>
                <div class="modal-body {{ modal_body_class }}">
                    {% block modal_body %}{% endblock %}
                </div>
    {% if modal_footer and modal_fixed_footer %}
            </div>
    {% endif %}
    {% if modal_footer %}
            <div class="modal-footer text-right {% if not modal_fixed_footer %}d-md-block{% endif %} {{ modal_footer_class }}">
                {% block modal_foot %}{% endblock %}
            </div>
        {% if modal_fixed_footer %}
        </div>
        {% endif %}
    {% endif %}

    {% if modal_form_action %}
    </form>
    {% endif %}
</div>
<div class="js-modal-overlay modal-overlay {% if modal_zindex_top %}modal-zindex-top{% endif %}" data-modal-id="#{{ modal_id }}" style="display: none;"></div>
