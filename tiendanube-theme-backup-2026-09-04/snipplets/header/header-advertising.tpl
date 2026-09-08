{% set has_advertising_bar = false %}
{% set num_messages = 0 %}
{% for adbar in ['ad_bar_01', 'ad_bar_02', 'ad_bar_03'] %}
    {% set advertising_text = attribute(settings,"#{adbar}_text") %}
    {% if advertising_text %}
        {% set has_advertising_bar = true %}
        {% set num_messages = num_messages + 1 %}
    {% endif %}
{% endfor %}

{% set animated_ad_bar = settings.ad_bar_animate %}

{% if settings.ad_bar and has_advertising_bar %}
    <section class="js-adbar section-adbar {% if settings.ad_bar_animate %}section-adbar-animated{% endif %}">
        <div class="{% if animated_ad_bar %}js-adbar-animated adbar-animated{% else %}js-swiper-adbar swiper-container container text-center {% endif %}">
            <div class="{% if animated_ad_bar %}js-adbar-text-container{% else %}swiper-wrapper{% endif %} align-items-center">
                {% if animated_ad_bar %}
                    {% if num_messages == 1 %}
                        {% set repeat_number = 16 %}
                    {% else %}
                        {% set repeat_number = num_messages == 2 ? '8' : '5' %}
                    {% endif %}
                {% else %}
                    {% set repeat_number = 1 %}
                {% endif %}
                
                {% for i in 1..repeat_number %}
                    {% for adbar in ['ad_bar_01', 'ad_bar_02', 'ad_bar_03'] %}
                        {% set advertising_text = attribute(settings,"#{adbar}_text") %}
                        {% set advertising_url = attribute(settings,"#{adbar}_url") %}
                        {% if advertising_text %}
                            <span class="{% if animated_ad_bar %}mr-4{% else %}swiper-slide slide-container px-4{% endif %}">
                                {% if advertising_url %}
                                    <a href="{{ advertising_url }}">
                                {% endif %}
                                {{ advertising_text }}
                                {% if advertising_url %}
                                    </a>
                                {% endif %}
                            </span>
                        {% endif %}
                    {% endfor %}
                {% endfor %}
            </div>
            {% if num_messages > 1 and not animated_ad_bar %}
                <div class="js-swiper-adbar-prev swiper-button-absolute swiper-button-prev svg-icon-text">
                    <svg class="icon-inline icon-sm icon-flip-horizontal"><use xlink:href="#chevron"/></svg>
                </div>
                <div class="js-swiper-adbar-next swiper-button-absolute swiper-button-next svg-icon-text ml-2">
                    <svg class="icon-inline icon-sm"><use xlink:href="#chevron"/></svg>
                </div>
            {% endif %}
        </div>
    </section>
{% endif %}
