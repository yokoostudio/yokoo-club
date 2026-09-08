{% if infinite_scroll %}
	{% if pages.current == 1 and not pages.is_last %}
		<div class="js-load-more text-center my-4">
			<a class="btn btn-default d-inline-block">
				{{ 'Mostrar más productos' | t }}
				<span class="js-load-more-spinner ml-2 mr-2 pl-1" style="display:none;">
					<svg class="icon-inline icon-spin icon-w-2em"><use xlink:href="#spinner-third"/></svg>
				</span>
			</a>
		</div>
		<div id="js-infinite-scroll-spinner" class="my-4 text-center w-100" style="display:none">
			<svg class="icon-inline icon-lg icon-spin icon-w-2em svg-icon-text"><use xlink:href="#spinner-third"/></svg>
		</div>
	{% endif %}
{% else %}
	<div class="row justify-content-center align-items-center mt-4">
		{% if pages.numbers %}
			<div class="col-auto p-0">
				<a {% if pages.previous %}href="{{ pages.previous }}"{% endif %} class="{% if not pages.previous %}opacity-30 disabled{% endif %} p-2">
					<svg class="icon-inline icon-lg svg-icon-text icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
				</a>
			</div>
			<div class="col-auto px-2">
				<div class="text-center">
					{% for page in pages.numbers %}
						{% if page.selected %}
							<span>{{ page.number }}</span>
						{% endif %}
					{% endfor %}
					<span>/</span>
					<span>{{ pages.amount }}</span>
				</div>
			</div>
			<div class="col-auto p-0">
				<a {% if pages.next %}href="{{ pages.next }}"{% endif %} class="{% if not pages.next %}opacity-30 disabled{% endif %} p-2">
					<svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#arrow-long"/></svg>
				</a>
			</div>
		{% endif %}
	</div>
{% endif %}