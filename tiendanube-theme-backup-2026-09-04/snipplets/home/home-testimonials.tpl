{% set has_home_testimonials = false %}
{% set num_testimonials = 0 %}
{% for testimonial in ['testimonial_01', 'testimonial_02', 'testimonial_03'] %}
	{% set testimonial_image = "#{testimonial}.jpg" | has_custom_image %}
	{% set testimonial_name = attribute(settings,"#{testimonial}_name") %}
	{% set testimonial_description = attribute(settings,"#{testimonial}_description") %}
	{% set has_testimonial = testimonial_name or testimonial_description or testimonial_image %}
	{% if has_testimonial %}
		{% set has_home_testimonials = true %}
		{% set num_testimonials = num_testimonials + 1 %}
	{% endif %}
{% endfor %}

{% if has_home_testimonials %}
	<section class="section-testimonials-home overflow-none{% if not settings.testimonials_title %} pt-4{% endif %}" data-store="home-testimonials">
		<div class="container">
			{% if settings.testimonials_title %}
				<h2 class="h3 mt-3 mb-4 text-center">{{ settings.testimonials_title }}</h2>
			{% endif %}
			<div class="row justify-content-center">
				<div class="col-md-6">
					<div class="js-swiper-testimonials swiper-testimonials swiper-container">
						<div class="swiper-wrapper">
							{% for testimonial in ['testimonial_01', 'testimonial_02', 'testimonial_03'] %}
								{% set testimonial_image = "#{testimonial}.jpg" | has_custom_image %}
								{% set testimonial_name = attribute(settings,"#{testimonial}_name") %}
								{% set testimonial_description = attribute(settings,"#{testimonial}_description") %}
								{% set has_testimonial = testimonial_name or testimonial_description or testimonial_image %}
								{% if has_testimonial %}
									<div class="swiper-slide">
										<div class="py-3 px-5 p-md-3 text-center">
											<div class="testimonials-image mb-3{% if not testimonial_image %} line{% endif %}">
												{% if testimonial_image %}
													<img class="testimonials-image-background lazyload" src="{{ 'images/empty-placeholder.png' | static_url }}" data-src='{{ "#{testimonial}.jpg" | static_url | settings_image_url("small") }}' {% if testimonial_name %}alt="{{ testimonial_name }}"{% else %}alt="{{ 'Testimonio de' | translate }} {{ store.name }}"{% endif %} />
														<div class="placeholder-fade"></div>
												{% else %}
													<svg class="icon-inline icon-lg"><use xlink:href="#quote"/></svg>
												{% endif %}
											</div>
											{% if testimonial_description %}
												<p class="mb-3 {% if settings.testimonials_italic %} font-italic{% endif %}">{{ testimonial_description }}</p>
											{% endif %}
											{% if testimonial_name %}
												<h3 class="h6 font-weight-bold {% if num_testimonials > 1 %}mb-0{% else %}mb-3{% endif %}">{{ testimonial_name }}</h3>
											{% endif %}
										</div>
									</div>
								{% endif %}
							{% endfor %}
						</div>
					</div>
					{% if num_testimonials > 1 %}
						<div class="text-center mb-2">
							<div class="js-swiper-testimonials-prev swiper-button-prev svg-icon-text">
								<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
							</div>
							<div class="js-swiper-testimonials-next swiper-button-next svg-icon-text">
								<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
							</div>
						</div>
					{% endif %}
				</div>
			</div>
		</div>
	</section>
{% endif %}
