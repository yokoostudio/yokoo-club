<ul class="list py-2 font-small">
	{% for item in menus[settings.footer_menu] %}
		<li class="footer-menu-item{% if loop.last %} mb-2{% endif %}">
	        <a class="footer-menu-link" href="{{ item.url }}" {% if item.url | is_external %}target="_blank"{% endif %}>{{ item.name }}</a>
		</li>
	{% endfor %}
</ul>