<ul class="list {% if footer %}font-small py-2{% else %}mb-4{% endif %}">
	{% if store.whatsapp %}
		<li class="{% if footer %}d-block {% endif %}mb-3">
			<a href="{{ store.whatsapp }}" class="{% if btn_link %}btn{% else %}contact{% endif %}-link">
				{% if with_icons %}
					<svg class="icon-inline mr-2 font-body"><use xlink:href="#whatsapp"/></svg>
				{% endif %}
				{{ store.whatsapp |trim('https://wa.me/') }}
			</a>
		</li>
	{% endif %}
	{% if store.phone %}
		<li class="{% if footer %}d-block {% endif %}mb-3">
			<a href="tel:{{ store.phone }}" class="{% if btn_link %}btn{% else %}contact{% endif %}-link">
				{% if with_icons %}
					<svg class="icon-inline mr-2 font-body"><use xlink:href="#phone"/></svg>
				{% endif %}
				{{ store.phone }}
			</a>
		</li>
	{% endif %}
	{% if store.email %}
		<li class="{% if footer %}d-block {% endif %}mb-3">
			<a href="mailto:{{ store.email }}" class="{% if btn_link %}btn{% else %}contact{% endif %}-link">
				{% if with_icons %}
					<svg class="icon-inline mr-2 font-body"><use xlink:href="#email"/></svg>
				{% endif %}
				{{ store.email }}
			</a>
		</li>
	{% endif %}
	{% if not phone_and_mail_only %}
		{% if store.address and not is_order_cancellation %}
			<li class="{% if footer %}d-block {% endif %}mb-3">
				{% if with_icons %}
					<svg class="icon-inline mr-2 font-body"><use xlink:href="#map-marker-alt"/></svg>
				{% endif %}
				{{ store.address }}
			</li>
		{% endif %}
		{% if store.blog %}
			<li class="{% if footer %}d-block {% endif %}mb-3">
				<a target="_blank" href="{{ store.blog }}" class="{% if btn_link %}btn{% else %}contact{% endif %}-link">
					{% if with_icons %}
						<svg class="icon-inline icon-w-2em mr-2 font-body"><use xlink:href="#comments"/></svg>
					{% endif %}
					{{ "¡Visitá nuestro Blog!" | translate }}
				</a>
			</li>
		{% endif %}
	{% endif %}
</ul>