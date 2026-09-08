<ul class="list-unstyled{% if header %} font-small{% endif %}">
    {% for language in languages %}
        <li class="{% if header %}{% if not loop.last %}mb-2{% endif %}{% else %}mb-4{% endif %}{% if language.active %} font-weight-bold{% endif %}">
            <a href="{{ language.url }}">
                {% if not header %}
                    <img class="lazyload mr-1" src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ language.country | flag_url }}" alt="{{ language.name }}" />
                {% endif %}
                {{ language.country_name }}
            </a>
        </li>
    {% endfor %}
</ul>
