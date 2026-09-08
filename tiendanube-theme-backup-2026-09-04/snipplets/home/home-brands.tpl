{% if settings.brands and settings.brands is not empty %}
	<section class="section-brands-home overflow-none{% if not settings.brands_title %} mt-3 pt-4{% endif %}" data-store="home-brands">
		<div class="container">
			{% if settings.brands_title %}
				<h2 class="h3 mt-3 mb-4 text-center">{{ settings.brands_title }}</h2>
			{% endif %}
			{% if settings.brands_format == 'slider' %}
				<div class="js-swiper-brands swiper-container text-center w-auto mx-4 m-md-0">
					<div class="js-swiper-brands-wrapper swiper-wrapper">
			{% else %}
				<div class="row mb-2 align-items-center">
			{% endif %}
					{% for slide in settings.brands %}
						<div class="{% if settings.brands_format == 'slider' %}swiper-slide slide-container{% else %}col-md-2 col-4 mb-4{% endif %} text-center">
							{% if slide.link %}
								<a href="{{ slide.link | setting_url }}" title="{{ 'Marca {1} de' | translate(loop.index) }} {{ store.name }}" aria-label="{{ 'Marca {1} de' | translate(loop.index) }} {{ store.name }}">
							{% endif %}
									<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ slide.image | static_url | settings_image_url('large') }}" class="lazyload fade-in brand-image" alt="{{ 'Marca {1} de' | translate(loop.index) }} {{ store.name }}">
									<div class="placeholder-fade"></div>
							{% if slide.link %}
								</a>
							{% endif %}
						</div>
					{% endfor %}
				</div>
			{% if settings.brands_format == 'slider' %}
				</div>
				<div class="text-center mt-3">
					<div class="js-swiper-brands-prev swiper-button-prev svg-icon-text">
						<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
					</div>
					<div class="js-swiper-brands-next swiper-button-next svg-icon-text">
						<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
					</div>
				</div>
			{% endif %}
		</div>
	</section>
{% endif %}
