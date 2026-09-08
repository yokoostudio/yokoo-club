<section class="section-testimonials-home overflow-none pt-4" data-store="home-testimonials">
	<h2 class="h3 mt-3 mb-4 text-center">{{ 'Testimonios' | translate }}</h2>
	<div class="row justify-content-center position-relative">
		<div class="col-md-6">
			<div class="js-swiper-testimonials-demo swiper-testimonials swiper-container">
				<div class="swiper-wrapper">
					<div class="swiper-slide">
						<div class="py-3 px-5 p-md-3 text-center">
							<div class="testimonials-image mb-3 line">
								<svg class="icon-inline icon-lg"><use xlink:href="#quote"/></svg>
							</div>
							<p class="mb-3">{{ 'Descripción del testimonio' | translate }}</p>
							<h3 class="h6 font-weight-bold mb-0">{{ 'Testimonio' | translate }}</h3>
						</div>
					</div>
					<div class="swiper-slide">
						<div class="py-3 px-5 p-md-3 text-center">
							<div class="testimonials-image mb-3 line">
								<svg class="icon-inline icon-lg"><use xlink:href="#quote"/></svg>
							</div>
							<p class="mb-3">{{ 'Descripción del testimonio' | translate }}</p>
							<h3 class="h6 font-weight-bold mb-0">{{ 'Testimonio' | translate }}</h3>
						</div>
					</div>
					<div class="swiper-slide">
						<div class="py-3 px-5 p-md-3 text-center">
							<div class="testimonials-image mb-3 line">
								<svg class="icon-inline icon-lg"><use xlink:href="#quote"/></svg>
							</div>
							<p class="mb-3">{{ 'Descripción del testimonio' | translate }}</p>
							<h3 class="h6 font-weight-bold mb-0">{{ 'Testimonio' | translate }}</h3>
						</div>
					</div>
				</div>
			</div>
			<div class="text-center mb-2">
				<div class="js-swiper-testimonials-prev-demo swiper-button-prev svg-icon-text">
					<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
				</div>
				<div class="js-swiper-testimonials-next-demo swiper-button-next svg-icon-text">
					<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
				</div>
			</div>
		</div>
		<div class="placeholder-overlay transition-soft">
			<div class="placeholder-info p-2">
				<svg class="icon-inline icon-2x"><use xlink:href="#edit"/></svg>
				<div class="placeholder-description font-small-xs my-2">
					{{ "Podés mostrar testimonios de tus clientes desde" | translate }} </br><strong>"{{ "Testimonios" | translate }}"</strong>
				</div>
				{% if not params.preview %}
					<a href="{{ admin_link }}#instatheme=pagina-de-inicio" class="btn-primary btn btn-small placeholder-button">{{ "Editar" | translate }}</a>
				{% endif %}
			</div>
		</div>
	</div>
</section>