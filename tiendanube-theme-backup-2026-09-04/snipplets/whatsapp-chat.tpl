{% if store.whatsapp %}
    <a href="{{ store.whatsapp }}" target="_blank" class="{% if header %}btn btn-utility{% else %}js-btn-fixed-bottom btn-whatsapp{% endif %}" aria-label="{{ 'Comunicate por WhatsApp' | translate }}">
        {% set whatsapp_icon_url = header ? '-line' : '' %}
        {% set whatsapp_icon_classes = header ? 'icon-inline utilities-icon' : '' %}
        <svg class="{{ whatsapp_icon_classes }}"><use xlink:href="#whatsapp{{ whatsapp_icon_url }}"/></svg>
    </a>
{% endif %}
