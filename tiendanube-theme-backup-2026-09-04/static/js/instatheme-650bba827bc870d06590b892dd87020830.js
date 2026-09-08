window.tiendaNubeInstaTheme = (function(jQueryNuvem) {
	return {
		waitFor: function() {
			return [];
		},
		placeholders: function() {
			return [
				{
					placeholder: '.js-home-slider-placeholder',
					content: '.js-home-slider-top',
					contentReady: function() {
						return $(this).find('img').length > 0;
					},
				},
				{
					placeholder: '.js-category-banner-placeholder',
					content: '.js-category-banner-top',
					contentReady: function() {
						return $(this).find('img').length > 0;
					},
				},
				{
					placeholder: '.js-promotional-banner-placeholder',
					content: '.js-promotional-banner-top',
					contentReady: function() {
						return $(this).find('img').length > 0;
					},
				},
				{
					placeholder: '.js-news-banner-placeholder',
					content: '.js-news-banner-top',
					contentReady: function() {
						return $(this).find('img').length > 0;
					},
				},
				{
					placeholder: '.js-module-banner-placeholder',
					content: '.js-module-banner-top',
					contentReady: function() {
						return $(this).find('img').length > 0;
					},
				},
			];
		},
		handlers: function(instaElements) {
			const handlers = {
				logo: new instaElements.Logo({
					$storeName: jQueryNuvem('#no-logo'),
					$logo: jQueryNuvem('#logo')
				}),
				// ----- Section order -----
				home_order_position: new instaElements.Sections({
					container: '.js-home-sections-container',
					data_store: {
						'slider': 'home-slider',
						'main_categories': 'home-categories-featured',
						'products': 'home-products-featured',
						'welcome': 'home-welcome-message',
						'institutional': 'home-institutional-message',
						'informatives': 'banner-services',
						'categories': 'home-banner-categories',
						'promotional': 'home-banner-promotional',
						'news_banners': 'home-banner-news',
						'modules': 'home-image-text-module',
						'new': 'home-products-new',
						'video': 'home-video',
						'sale': 'home-products-sale',
						'instafeed': 'home-instagram-feed',
						'main_product': 'home-product-main',
						'brands': 'home-brands',
						'testimonials': 'home-testimonials',
						'newsletter' : 'home-newsletter',
					}
				}),
			};

			// ----------------------------------- Slider -----------------------------------

			// Build the html for a slide given the data from the settings editor
			function buildHomeSlideDom(aSlide, imageClasses) {
				return '<div class="swiper-slide slide-container ' + aSlide.color + '">' +
							(aSlide.link ? '<a href="' + aSlide.link + '">' : '' ) +
								'<img src="' + aSlide.src + '" class="js-slider-image slider-image ' + imageClasses + '"/>' +
								'<div class="swiper-text swiper-text-centered swiper-text-' + aSlide.color + '">' +
									(aSlide.title ? '<div class="h1-huge mb-1">' + aSlide.title + '</div>' : '' ) +
									(aSlide.description ? '<p class="mb-2">' + aSlide.description + '</p>' : '' ) +
									(aSlide.button && aSlide.link ? '<div class="btn-link">' + aSlide.button + '</div>' : '' ) +
								'</div>' +
							(aSlide.link ? '</a>' : '' ) +
						'</div>'
			}

			// Update slider animation
			handlers.slider_animation = new instaElements.Lambda(function(sliderAnimation){
				const $swiperImage = $('.js-home-slider-container').find('.js-slider-image');
				const $homeSlider = $('.js-home-slider, .js-home-slider-mobile');

				if (sliderAnimation) {
					$homeSlider.attr('data-animation', 'true');
					$swiperImage.addClass('slider-image-animation');
				} else {
					$homeSlider.attr('data-animation', 'false');
					$swiperImage.removeClass('slider-image-animation');
				}
			});

			// Update main slider
			handlers.slider = new instaElements.Lambda(function(slides){
				if (!window.homeSwiper) {
					return;
				}

				// Update animation classes
				const sliderAnimation = $('.js-home-slider').attr('data-animation');
				const imageClasses = sliderAnimation == 'true' ? 'slider-image-animation' : '';

				window.homeSwiper.removeAllSlides();
				slides.forEach(function(aSlide){
					window.homeSwiper.appendSlide(buildHomeSlideDom(aSlide, imageClasses));
				});
				window.homeSwiper.update();
			});

			// Update mobile slider
			handlers.slider_mobile = new instaElements.Lambda(function(slides){
				// This slider is not included in the html if `toggle_slider_mobile` is not set.
				// The second condition could be removed if live preview for this checkbox is implemented but changing the viewport size forces a refresh, so it's not really necessary.
				if (!window.homeMobileSwiper || !window.homeMobileSwiper.slides) {
					return;
				}

				// Update animation classes
				const sliderAnimation = $('.js-home-slider-mobile').attr('data-animation');
				const imageClasses = sliderAnimation == 'true' ? 'slider-image-animation' : '';

				window.homeMobileSwiper.removeAllSlides();
				slides.forEach(function(aSlide){
					window.homeMobileSwiper.appendSlide(buildHomeSlideDom(aSlide, imageClasses));
				});
				window.homeMobileSwiper.update();
			});

			// Update slider full
			handlers.slider_full = new instaElements.Lambda(function(sliderFull){
				const $section = $('.js-home-slider-section');
				const $container = $('.js-home-slider-container');
				const $row = $('.js-home-slider-row');

				if (sliderFull) {
					$section.removeClass('mt-4');
					$container.removeClass('container').addClass('container-fluid p-0');
					$row.addClass('no-gutters');

					// Updates slider width to avoids swipes inconsistency
					window.homeSwiper.params.observer = true;
					window.homeSwiper.update();

				} else {
					$section.addClass('mt-4');
					$container.removeClass('container-fluid p-0').addClass('container');
					$row.removeClass('no-gutters');

					// Updates slider width to avoids swipes inconsistency
					window.homeSwiper.params.observer = true;
					window.homeSwiper.update();
				}
			});

			// ----------------------------------- Main Banners -----------------------------------

			// Build the html for a slide given the data from the settings editor

			var slideCount = 0;

			function buildHomeBannerDom(aSlide, bannerClasses, textBannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses, bannerModule) {
				slideCount++;
				var evenClass = slideCount % 2 === 0 ? '' : 'order-md-first';
				var bannerTitleClass = columnClasses == 'col-md-3' && !bannerModule ? 'h1-huge h3-md' : 'h1-huge';
				return '<div class="js-banner ' + bannerClasses + ' ' + columnClasses + '">' +
						'<div class="js-textbanner textbanner ' + textBannerClasses + '">' +
							(aSlide.link ? '<a href="' + aSlide.link + '">' : '' ) +
								(bannerModule ? '<div class="row no-gutters align-items-center text-center">' : '' ) +
									'<div class="js-textbanner-image-container textbanner-image overflow-none ' + (bannerModule ? 'col-md-6 ' : '') + imageContainerClasses + '">' +
										'<img src="' + aSlide.src + '" class="js-textbanner-image textbanner-image-effect ' + imageClasses + '">' +
									'</div>' +
									(aSlide.title || aSlide.description || aSlide.button ? '<div class="js-textbanner-text textbanner-text ' + (bannerModule ? 'col-md-6 px-3 px-md-4 ' + evenClass : '') + textClasses + '">' : '') +
										(aSlide.title ? '<div class="my-2 ' + (bannerModule ? 'h3' : 'js-banner-title ' + bannerTitleClass) + '">' + aSlide.title + '</div>' : '' ) +
										(aSlide.description ? '<div class="textbanner-paragraph ' + (aSlide.button && aSlide.link ? 'mb-3' : '') + '">' + aSlide.description + '</div>' : '' ) +
										(aSlide.button && aSlide.link ? '<div class="btn-link">' + aSlide.button + '</div>' : '' ) +
									(aSlide.title || aSlide.description || aSlide.button ? '</div>' : '') +
								(bannerModule ? '</div>' : '' ) +
							(aSlide.link ? '</a>' : '' ) +
						'</div>' +
					'</div>'
			}

			// Build swiper JS for Banners

			function initSwiperJS(bannerMainContainer, swiperId, swiperName, isModule){

				const swiperDesktopColumns = isModule ? 1 : bannerMainContainer.attr('data-desktop-columns');
				const bannerMargin = bannerMainContainer.attr('data-margin');
				const bannerSpaceBetween = bannerMargin == 'false' ? 0 : 30;

				// Initialize swiper
				createSwiper(`.js-swiper-${swiperId}`, {
					watchOverflow: true,
					centerInsufficientSlides: true,
					threshold: 5,
					watchSlideProgress: true,
					watchSlidesVisibility: true,
					slideVisibleClass: 'js-swiper-slide-visible',
					spaceBetween: bannerSpaceBetween,
					navigation: {
						nextEl: `.js-swiper-${swiperId}-next`,
						prevEl: `.js-swiper-${swiperId}-prev`
					},
					pagination: {
						el: `.js-swiper-${swiperId}-pagination`,
						type: 'fraction',
					},
					breakpoints: {
						768: {
							slidesPerView: swiperDesktopColumns,
						}
					}
				},
				function(swiperInstance) {
					window[swiperName] = swiperInstance;
				});

			}

			// Main banners: Banner content and order updates. General layout and format updates (for main and secondary banners)

			['banner', 'banner_promotional', 'module', 'banner_news'].forEach(setting => {

				const bannerName = setting.replace('_', '-');
				const bannerPluralName = 
					setting == 'banner' ? 'banners' : 
					setting == 'banner_promotional' ? 'banners-promotional' : 
					setting == 'banner_news' ? 'banners-news' : 
					setting == 'module' ? 'modules' :
					null;

				const isModule = setting == 'module';
				const $generalBannersContainer = $(`.js-home-${bannerName}`);

				// Main banner
				const $mainBannersContainer = $generalBannersContainer.find(`.js-${bannerPluralName}`);

				const $bannerItem = $generalBannersContainer.find('.js-banner');

				// Mobile banner - posible if !module
				const bannerMobileName = 
					setting == 'banner' ? 'banners-mobile' : 
					setting == 'banner_promotional' ? 'banners-promotional-mobile' : 
					setting == 'banner_news' ? 'banners-news-mobile' :
					null;
				const $mobileBannersContainer = $generalBannersContainer.find(`.js-${bannerMobileName}`);

				const bannerSwiper = 
					setting == 'banner' ? 'homeBannerSwiper' : 
					setting == 'banner_promotional' ? 'homeBannerPromotionalSwiper' : 
					setting == 'banner_news' ? 'homeBannerNewsSwiper' : 
					setting == 'module' ? 'homeModuleSwiper' :
					null;

				// Used for specific mobile images swiper updates - posibble if !module
				const bannerSwiperMobile = 
					setting == 'banner' ? 'homeBannerMobileSwiper' : 
					setting == 'banner_promotional' ? 'homeBannerPromotionalMobileSwiper' : 
					setting == 'banner_news' ? 'homeBannerNewsMobileSwiper' :
					null;

				const bannerModuleSetting = setting == 'module' ? true : false;
				const bannerFormat = $generalBannersContainer.attr('data-format');

				const desktopColumns = $generalBannersContainer.attr('data-desktop-columns');

				// Update section title

				handlers[`${setting}_title`] = new instaElements.Lambda(function(title){
					const $bannersMainTitle = $generalBannersContainer.find('.js-banners-section-title');
					if (title) {
						$bannersMainTitle.show();
						$bannersMainTitle.text(title);
					} else {
						$bannersMainTitle.hide();
					}
				});

				// Update banners content and order

				handlers[`${setting}`] = new instaElements.Lambda(function(slides){

					// Update text classes
					const textPosition = $generalBannersContainer.attr('data-text');
					const textClasses = textPosition == 'above' ? 'over-image' : '';
					const backgroundClasses = textPosition == 'outside' ? 'background-secondary' : '';

					// Update margin classes
					const bannerMargin = $generalBannersContainer.attr('data-margin');
					const marginClasses = 
						bannerMargin == 'false' ? 'm-0' : 
						isModule && (bannerMargin == 'true' || bannerFormat == 'grid') ? ' mb-md-5 pb-md-5'  : '';

					// Update align classes
					const bannerAlign = $generalBannersContainer.attr('data-align');
					const alignClasses = bannerAlign == 'center' ? 'text-center' : 'textbanner-text-left';

					// Update textbanner classes
					const textBannerClasses = marginClasses + ' ' + backgroundClasses + ' ' + alignClasses;

					// Update image classes
					const imageSize = $generalBannersContainer.attr('data-image');
					const imageClasses = imageSize == 'same' ? 'textbanner-image-background' : 'img-fluid d-block w-100';
					const imageContainerClasses = 
						imageSize == 'original' ? 'p-0' : 
						isModule && imageSize == 'same' ? 'textbanner-image-md' : '';

					const bannerFormat = $generalBannersContainer.attr('data-format');

					if (bannerFormat == 'slider') {
						// Update banner classes
						const bannerClasses = 'swiper-slide';
						// Avoids columnsClasses on slider
						const columnClasses = '';

						if (!window[bannerSwiper]) {
							return;
						}

						// Try using already created swiper JS, if it fails initialize swipers again
						try{
							window[bannerSwiper].removeAllSlides();
							slides.forEach(function(aSlide){
								window[bannerSwiper].appendSlide(buildHomeBannerDom(aSlide, bannerClasses, textBannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses, bannerModuleSetting));
							});
							window[bannerSwiper].update();
						}catch(e){
							initSwiperJS($generalBannersContainer, bannerPluralName, bannerSwiper, isModule);

							setTimeout(function(){
								slides.forEach(function(aSlide){
									window[bannerSwiper].appendSlide(buildHomeBannerDom(aSlide, bannerClasses, textBannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses, bannerModuleSetting));
								});	
							},500);
						}
					} else {
						// Update banner classes
						const bannerClasses = isModule ? '' : 'col-grid';
						// Update column classes
						const desktopColumnsClasses = $generalBannersContainer.attr('data-grid-classes');
						const columnClasses = desktopColumnsClasses;

						$mainBannersContainer.find('.swiper-slide-duplicate').remove();
						$mainBannersContainer.find(`.js-swiper-${bannerPluralName}-prev`).remove();
						$mainBannersContainer.find(`.js-swiper-${bannerPluralName}-next`).remove();
						$mainBannersContainer.find('.js-banner').remove();

						slides.forEach(function(aSlide){
							$mainBannersContainer.find('.js-banner-row').append(buildHomeBannerDom(aSlide, bannerClasses, textBannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses, bannerModuleSetting));
						});
					}

					$generalBannersContainer.data('format', bannerFormat);
				});

				function initSwiperElements(bannerRow, swiperId, swiperName, isModule) {

					const bannerMargin = $generalBannersContainer.attr('data-margin');
					const bannerMarginClasses = isModule ? 'justify-content-center' : bannerMargin == 'false' ? 'row no-gutters justify-content-center' : 'row justify-content-center';

					const $bannerItem = $generalBannersContainer.find('.js-banner');

					$bannerItem.removeClass('col-grid col-6 col-md-3 col-md-4 col-md-6 col-md-12');
					$bannerItem.removeClass('mb-md-5 pb-md-5');

					// Row to swiper wrapper
					bannerRow.removeClass(bannerMarginClasses).addClass('swiper-wrapper');

					// Wrap everything inside a swiper container
					bannerRow.wrapAll(`<div class="js-swiper-${swiperId} swiper-container"></div>`);

					// Replace each banner into a slide
					$bannerItem.addClass('swiper-slide');

					// Add previous and next controls
					bannerRow.after(`
						<div class="js-swiper-${swiperId}-controls text-center">
							<div class="js-swiper-${swiperId}-prev swiper-button-prev svg-icon-text">
								<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
							</div>
							<div class="js-swiper-${swiperId}-pagination swiper-pagination-fraction"></div>
							<div class="js-swiper-${swiperId}-next swiper-button-next svg-icon-text">
								<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
							</div>
						</div>
					`);

					
					// Initialize swiper

					initSwiperJS($generalBannersContainer, swiperId, swiperName, isModule);
				}

				// Build grid markup and reset swiper

				function resetSwiperElements(bannersGroupContainer, bannerRow, swiperId, isModule) {
					const desktopColumnsClasses = $generalBannersContainer.attr('data-grid-classes');
					const columnClasses = desktopColumnsClasses;
					const bannerClasses = isModule ? '' : 'col-grid ' + columnClasses;

					const bannerMargin = $generalBannersContainer.attr('data-margin');
					const bannerMarginClasses = isModule ? '' : bannerMargin == 'false' ? 'row no-gutters justify-content-center' : 'row justify-content-center';

					const $bannerItem = $generalBannersContainer.find('.js-banner');

					// Remove duplicate slides and slider controls
					bannersGroupContainer.find('.swiper-slide-duplicate').remove();
					bannersGroupContainer.find(`.js-swiper-${swiperId}-controls`).remove();

					// Swiper wrapper to row
					bannerRow.removeClass('swiper-wrapper').addClass(bannerMarginClasses).removeAttr('style');

					// Undo all slider wrappers and restore original classes
					bannerRow.unwrap();
					$bannerItem
						.removeClass('js-swiper-slide-visible swiper-slide-active swiper-slide-next swiper-slide-prev swiper-slide')
						.addClass(bannerClasses)
						.removeAttr('style');
				}

				// Toggle grid and slider format

				handlers[`${setting}_slider`] = new instaElements.Lambda(function(bannerSlider){

					// Main banners markup container
					const $mainBannerRow = $mainBannersContainer.find('.js-banner-row');

					// Mobile banners markup container
					const $bannerMobileRow = $mobileBannersContainer.find('.js-banner-row');

					if (bannerSlider) {
						$generalBannersContainer.attr('data-format', 'slider');
					} else {
						$generalBannersContainer.attr('data-format', 'grid');
					}

					// Update margin classes
					const bannerMargin = $generalBannersContainer.attr('data-margin');
					const marginClasses = bannerMargin == 'false' ? 'm-0' : '';

					const bannerFormat = $generalBannersContainer.attr('data-format');

					const toSlider = bannerFormat == "slider";

					if ($generalBannersContainer.data('format') == bannerFormat) {
						// Nothing to do
						return;
					}

					// From grid to slider
					if (toSlider) {

						initSwiperElements($mainBannerRow, bannerPluralName, bannerSwiper, isModule);
						if (!isModule) {
							initSwiperElements($bannerMobileRow, bannerMobileName, bannerSwiperMobile);
						}

					// From slider to grid
					} else {
						resetSwiperElements($mainBannersContainer, $mainBannerRow, bannerPluralName, isModule);
						if (!isModule) {
							resetSwiperElements($mobileBannersContainer, $bannerMobileRow, bannerMobileName, isModule);
						}

						// Add margin if modules
						if (isModule && bannerMargin == 'true') {
							$bannerItem.addClass('mb-md-5 pb-md-5');
						}
					}

					// Persist new format in data attribute
					$generalBannersContainer.data('format', bannerFormat);
				});

				// Update banner text position

				handlers[`${setting}_text_outside`] = new instaElements.Lambda(function(hasOutsideText){
					const $bannerItem = $generalBannersContainer.find('.js-textbanner');
					const $bannerText = $generalBannersContainer.find('.js-textbanner-text');
					const $bannerLight = $bannerItem.hasClass('text-light');

					if (hasOutsideText) {
						$generalBannersContainer.attr('data-text', 'outside');
						$bannerText.removeClass('over-image').addClass('background-secondary');
						if ($bannerLight) {
							$bannerText.removeClass('text-light');
						}
					} else {
						$generalBannersContainer.attr('data-text', 'above');
						$bannerText.removeClass('background-secondary').addClass('over-image');
						if ($bannerLight) {
							$bannerText.addClass('text-light');
						}
					}
				});

				// Update banner size

				handlers[`${setting}_same_size`] = new instaElements.Lambda(function(bannerSize){
					const $bannerImageContainer = $generalBannersContainer.find('.js-textbanner-image-container');
					const $bannerImage = $generalBannersContainer.find('.js-textbanner-image');

					if (bannerSize) {
						$generalBannersContainer.attr('data-image', 'same');
						$bannerImageContainer.removeClass('p-0');
						$bannerImage.removeClass('img-fluid d-block w-100').addClass('textbanner-image-background');
					} else {
						$generalBannersContainer.attr('data-image', 'original');
						$bannerImageContainer.addClass('p-0');
						$bannerImage.removeClass('textbanner-image-background').addClass('img-fluid d-block w-100');
					}
				});

				// Update banner margins

				handlers[`${setting}_without_margins`] = new instaElements.Lambda(function(bannerMargin){
					const $bannerContainer = $generalBannersContainer.find('.js-banner-container');
					const $bannerRow = $bannerContainer.find('.js-banner-row:not(.swiper-wrapper)');
					const $bannerMainTitle = $(`.js-${bannerPluralName}-title`);
					const $bannerItem = $generalBannersContainer.find('.js-textbanner');
					const bannerFormat = $generalBannersContainer.attr('data-format');

					if (isModule) {
						$bannerContainer.find('.js-banner-row').removeClass('row');
						$bannerRow.removeClass('justify-content-center');
					}

					if (bannerMargin) {
						$generalBannersContainer.attr('data-margin', 'false');
						$bannerContainer.removeClass('container').addClass('container-fluid p-0 overflow-none');
						$bannerRow.addClass('no-gutters');
						$bannerMainTitle.addClass('container');
						$bannerItem.removeClass('mb-md-5 pb-md-5').addClass('m-0');
						if (bannerFormat == 'slider') {
							window[bannerSwiper].params.spaceBetween = 0;
							if (!isModule) {
								window[bannerSwiperMobile].params.spaceBetween = 0;
							}
						}
					} else {
						$generalBannersContainer.attr('data-margin', 'true');
						$bannerContainer.removeClass('container-fluid p-0 overflow-none').addClass('container');
						$bannerRow.removeClass('no-gutters');
						$bannerMainTitle.removeClass('container');
						$bannerItem.removeClass('m-0');
						if (bannerFormat == 'slider') {
							window[bannerSwiper].params.spaceBetween = 30;
							if (!isModule) {
								window[bannerSwiperMobile].params.spaceBetween = 30;
							}
						} else {
							if (isModule) {
								$bannerItem.addClass('mb-md-5 pb-md-5');
							}
						}
					}

					// Updates slider width to avoids swipes inconsistency
					if (bannerFormat == 'slider') {
						
						// Try using already created swiper JS, if it fails initialize swipers again
						try{
							window[bannerSwiper].params.observer = true;
							window[bannerSwiper].update();

							if (!isModule) {
							window[bannerSwiperMobile].params.observer = true;
								window[bannerSwiperMobile].update();
							}
						}catch(e){
							initSwiperJS($generalBannersContainer, bannerPluralName, bannerSwiper);
							initSwiperJS($generalBannersContainer, bannerMobileName, bannerSwiperMobile);
						}
					}
				});

				if (!isModule) {

					// Update banner text align
					handlers[`${setting}_align`] = new instaElements.Lambda(function(bannerAlign){
						const $bannerText = $generalBannersContainer.find('.js-textbanner');

						if (bannerAlign == 'left') {
							$generalBannersContainer.attr('data-align', 'left');
							$bannerText.removeClass('text-center').addClass('textbanner-text-left');
						} else {
							$generalBannersContainer.attr('data-align', 'center');
							$bannerText.removeClass('textbanner-text-left').addClass('text-center');
						}
					});

					// Update quantity desktop banners

					handlers[`${setting}_columns_desktop`] = new instaElements.Lambda(function(bannerQuantity){
						const $bannerItem = $generalBannersContainer.find('.js-banner');
						const bannerFormat = $generalBannersContainer.attr('data-format');

						$bannerItem.removeClass('col-md-3 col-md-4 col-md-6 col-md-12');
						$generalBannersContainer.find('.js-banner-title').removeClass("h3-md");

						if (bannerQuantity == 4) {
							$generalBannersContainer.attr('data-desktop-columns', bannerQuantity);
							$generalBannersContainer.attr('data-grid-classes', 'col-md-3');

							if (bannerFormat == 'grid') {
								$bannerItem.addClass('col-md-3');
							} else {
								if (window.innerWidth > 768) {
									window[bannerSwiper].params.slidesPerView = 4;
								}
							}
							if(!isModule){
								$generalBannersContainer.find('.js-banner-title').addClass("h3-md");
							}
							
						} else if (bannerQuantity == 3) {
							$generalBannersContainer.attr('data-desktop-columns', bannerQuantity);
							$generalBannersContainer.attr('data-grid-classes', 'col-md-4');

							if (bannerFormat == 'grid') {
								$bannerItem.addClass('col-md-4');
							} else {
								if (window.innerWidth > 768) {
									window[bannerSwiper].params.slidesPerView = 3;
								}
							}
						} else if (bannerQuantity == 2) {
							$generalBannersContainer.attr('data-desktop-columns', bannerQuantity);
							$generalBannersContainer.attr('data-grid-classes', 'col-md-6');

							if (bannerFormat == 'grid') {
								$bannerItem.addClass('col-md-6');
							} else {
								if (window.innerWidth > 768) {
									window[bannerSwiper].params.slidesPerView = 2;
								}
							}
						} else if (bannerQuantity == 1) {
							$generalBannersContainer.attr('data-desktop-columns', bannerQuantity);
							$generalBannersContainer.attr('data-grid-classes', 'col-md-12');

							if (bannerFormat == 'grid') {
								$bannerItem.addClass('col-md-12');
							} else {
								if (window.innerWidth > 768) {
									window[bannerSwiper].params.slidesPerView = 1;
								}
							}
						}

						if (bannerFormat == 'slider') {
							// Try using already created swiper JS, if it fails initialize swipers again
							try{
								window[bannerSwiper].update();
								window[bannerSwiperMobile].update();
							}catch(e){
								initSwiperJS($generalBannersContainer, bannerPluralName, bannerSwiper);
								initSwiperJS($generalBannersContainer, bannerMobileName, bannerSwiperMobile);
							}
						}
					});

					// Toggle mobile banners visibility

					handlers[`toggle_${setting}_mobile`] = new instaElements.Lambda(function(showMobileBanner){
						const bannerFormat = $generalBannersContainer.attr('data-format');

						$mainBannersContainer.removeClass("hidden d-md-none d-none d-md-block");
						$mobileBannersContainer.removeClass("hidden d-md-none d-none d-md-block");

						if (showMobileBanner) {
							// Each breakpoint shows on it's own device content
							$mainBannersContainer.addClass("d-none d-md-block");
							$mobileBannersContainer.addClass("d-md-none");
							$generalBannersContainer.attr('data-mobile-banners', '1');
							if (bannerFormat == 'slider') {
								// Try using already created swiper JS, if it fails initialize swipers again
								try{
									window[bannerSwiperMobile].update();
								}catch(e){
									initSwiperJS($generalBannersContainer, bannerMobileName, bannerSwiperMobile);
								}
							}
						} else {
							// Hide mobile banners
							$mobileBannersContainer.addClass("d-none");
							$generalBannersContainer.attr('data-mobile-banners', '0');
							if (bannerFormat == 'slider') {
								// Try using already created swiper JS, if it fails initialize swipers again
								try{
									window[bannerSwiper].update();
								}catch(e){
									initSwiperJS($generalBannersContainer, bannerPluralName, bannerSwiper);
								}
							}
						}
					});
				}

			});

			// Mobile banners: Banner content and order updates

			['banner_mobile', 'banner_promotional_mobile', 'banner_news_mobile'].forEach(setting => {

				const bannerName = setting.replace('_', '-').replace(/[-_]mobile$/, '');
				const bannerMobileName = 
					setting == 'banner_mobile' ? 'banners-mobile' : 
					setting == 'banner_promotional_mobile' ? 'banners-promotional-mobile' : 
					setting == 'banner_news_mobile' ? 'banners-news-mobile' :
					null;
				const $generalBannersContainer = $(`.js-home-${bannerName}`);

				// Target specific breakpoint to build correct slides on each device
				const $mobileBannersContainer = $generalBannersContainer.find(`.js-${bannerMobileName}`);

				const bannerSwiperMobile = 
					setting == 'banner_mobile' ? 'homeBannerMobileSwiper' : 
					setting == 'banner_promotional_mobile' ? 'homeBannerPromotionalMobileSwiper' : 
					setting == 'banner_news_mobile' ? 'homeBannerNewsMobileSwiper' :
					null;

				const desktopColumns = $generalBannersContainer.data('desktop-columns');

				// Update banners content and order

				handlers[`${setting}`] = new instaElements.Lambda(function(slides){

					// Update text classes
					const textPosition = $generalBannersContainer.attr('data-text');
					const textClasses = textPosition == 'above' ? 'over-image' : '';
					const backgroundClasses = textPosition == 'outside' ? 'background-secondary' : '';

					// Update margin classes
					const bannerMargin = $generalBannersContainer.attr('data-margin');
					const marginClasses = bannerMargin == 'false' ? 'm-0' : '';

					// Update align classes
					const bannerAlign = $generalBannersContainer.attr('data-align');
					const alignClasses = bannerAlign == 'center' ? 'text-center' : 'textbanner-text-left';

					// Update textbanner classes
					const textBannerClasses = marginClasses + ' ' + backgroundClasses + ' ' + alignClasses;

					// Update image classes
					const imageSize = $generalBannersContainer.attr('data-image');
					const imageClasses = imageSize == 'same' ? 'textbanner-image-background' : 'img-fluid d-block w-100';
					const imageContainerClasses = imageSize == 'original' ? 'p-0' : '';

					const bannerFormat = $generalBannersContainer.attr('data-format');
					const bannerModuleSetting = false;
					const isModule = false;

					if (bannerFormat == 'slider') {
						// Update banner classes
						const bannerClasses = 'swiper-slide';
						// Avoids columnsClasses on slider
						const columnClasses = '';

						if (!window[bannerSwiperMobile]) {
							return;
						}

						// Try using already created swiper JS, if it fails initialize swipers again
						try{
							window[bannerSwiperMobile].removeAllSlides();
							slides.forEach(function(aSlide){
								window[bannerSwiperMobile].appendSlide(buildHomeBannerDom(aSlide, bannerClasses, textBannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses, bannerModuleSetting));
							});	
							window[bannerSwiperMobile].update();
						}catch(e){
							initSwiperJS($generalBannersContainer, bannerMobileName, bannerSwiperMobile, isModule);
							setTimeout(function(){
								window[bannerSwiperMobile].removeAllSlides();
								slides.forEach(function(aSlide){
									window[bannerSwiperMobile].appendSlide(buildHomeBannerDom(aSlide, bannerClasses, textBannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses, bannerModuleSetting));
								});	
							},500);
						}
					} else {
						// Update banner classes
						const bannerClasses = 'col-grid';
						// Update column classes
						const desktopColumnsClasses = $generalBannersContainer.attr('data-grid-classes');
						const columnClasses = desktopColumnsClasses;

						$mobileBannersContainer.find('.swiper-slide-duplicate').remove();
						$mobileBannersContainer.find(`.js-swiper-${bannerMobileName}-prev`).remove();
						$mobileBannersContainer.find(`.js-swiper-${bannerMobileName}-next`).remove();

						$mobileBannersContainer.find('.js-banner').remove();
						slides.forEach(function(aSlide){
							$mobileBannersContainer.find('.js-banner-row').append(buildHomeBannerDom(aSlide, bannerClasses, textBannerClasses, columnClasses, textClasses, imageContainerClasses, imageClasses, false));
						});
					}

					$generalBannersContainer.data('format', bannerFormat);
				});
			});

			// ----------------------------------- Welcome Message -----------------------------------

			// Update welcome message title
			handlers.welcome_message = new instaElements.Text({
				element: '.js-welcome-message-title',
				show: function(){
					$(this).show();
				},
				hide: function(){
					$(this).hide();
				},
			});

			// Update welcome message subtitle
			handlers.welcome_text = new instaElements.Text({
				element: '.js-welcome-message-text',
				show: function(){
					$(this).show();
				},
				hide: function(){
					$(this).hide();
				},
			});

			// Update welcome message button
			handlers.welcome_button = new instaElements.Text({
				element: '.js-welcome-message-button',
				show: function() {
					if ($(this).data('has-url')) {
						$(this).show();
					} else {
						$(this).hide();
					}
				},
				hide: function() {
					$(this).hide();
				}
			});

			// Toggle has-url data attribute which is used in the show/hide logic of the button above
			handlers.welcome_link = new instaElements.Lambda(function(value){
				const $button = $('.js-welcome-message-button');

				$button.data('has-url', !!value);
				if (value && $button.text().trim()) {
					$button.show();
				} else {
					$button.hide();
				}

			});

			// Update italic style
			handlers.welcome_italic = new instaElements.Lambda(function(welcomeItalic){
				const $welcomeText = $('.js-welcome-message-text');
				if (welcomeItalic) {
					$welcomeText.addClass('font-italic');
				} else {
					$welcomeText.removeClass('font-italic');
				}
			});

			// ----------------------------------- Institutional Message -----------------------------------

			// Update institutional message title
			handlers.institutional_message = new instaElements.Text({
				element: '.js-institutional-message-title',
				show: function(){
					$(this).show();
				},
				hide: function(){
					$(this).hide();
				},
			});

			// Update institutional message subtitle
			handlers.institutional_text = new instaElements.Text({
				element: '.js-institutional-message-text',
				show: function(){
					$(this).show();
				},
				hide: function(){
					$(this).hide();
				},
			});

			// Update italic style
			handlers.institutional_italic = new instaElements.Lambda(function(institutionalItalic){
				const $institutionalText = $('.js-institutional-message-text');
				if (institutionalItalic) {
					$institutionalText.addClass('font-italic');
				} else {
					$institutionalText.removeClass('font-italic');
				}
			});

			// Update institutional message button
			handlers.institutional_button = new instaElements.Text({
				element: '.js-institutional-message-button',
				show: function() {
					if ($(this).data('has-url')) {
						$(this).show();
					} else {
						$(this).hide();
					}
				},
				hide: function() {
					$(this).hide();
				}
			});

			// Toggle has-url data attribute which is used in the show/hide logic of the button above
			handlers.institutional_link = new instaElements.Lambda(function(value){
				const $button = $('.js-institutional-message-button');

				$button.data('has-url', !!value);
				if (value && $button.text().trim()) {
					$button.show();
				} else {
					$button.hide();
				}

			});

			// ----------------------------------- Highlighted Products -----------------------------------

			// Same logic applies to all 3 types of highlighted products

			['featured', 'sale', 'new'].forEach(setting => {

				const $productContainer = $(`.js-products-${setting}-container`);
				const $productGrid = $(`.js-products-${setting}-grid`);
				const productSwiper = 
					setting == 'featured' ? 'productsFeaturedSwiper' : 
					setting == 'new' ? 'productsNewSwiper' : 
					setting == 'sale' ? 'productsSaleSwiper' :
					null;

				const $productItem = $productGrid.find(`.js-item-product`);
				const $productItemInfoContainer = $productGrid.find(`.js-item-info-container`);

				// Updates title text
				handlers[`${setting}_products_title`] = new instaElements.Text({
					element: `.js-products-${setting}-title`,
					show: function(){
						$(this).show();
					},
					hide: function(){
						$(this).hide();
					},
				})

				// Updates quantity products desktop
				handlers[`${setting}_products_desktop`] = new instaElements.Lambda(function(desktopProductQuantity){
					if (window.innerWidth > 768) {
						const productFormat = $productGrid.attr('data-format');
						$productItem.removeClass('col-grid col-md-3 col-md-4 col-md-6');
						$productGrid.attr('data-desktop-columns', desktopProductQuantity);
						if (productFormat == 'grid') {
							if (desktopProductQuantity == 4) {
								$productItem.addClass('col-md-3');
							} else if (desktopProductQuantity == 3) {
								$productItem.addClass('col-md-4');
							} else if (desktopProductQuantity == 2) {
								$productItem.addClass('col-md-6');
							}
						}else{
							window[productSwiper].params.slidesPerView = desktopProductQuantity;
							window[productSwiper].update();
						}
						
					}
				});

				// Updates quantity products mobile
				handlers[`${setting}_products_mobile`] = new instaElements.Lambda(function(mobileProductQuantity){
					if (window.innerWidth < 768) {
						$productItem.removeClass('col-6 col-12');
						const productFormat = $productGrid.attr('data-format');
						$productGrid.attr('data-mobile-columns', mobileProductQuantity);
						if (productFormat == 'grid') {
							if (mobileProductQuantity == 1) {
								$productItem.addClass('col-12');

							} else if (mobileProductQuantity == 2) {
								$productItem.addClass('col-6');
							}
						}else{
							window[productSwiper].params.slidesPerView = mobileProductQuantity;
							window[productSwiper].update();
						}
					}
				});

				// Initialize swiper function
				function initSwiperElements() {
					const desktopProductQuantity = $productGrid.attr('data-desktop-columns');
					const mobileProductQuantity = $productGrid.attr('data-mobile-columns');

					$productGrid.addClass('swiper-wrapper').removeClass("row row-grid");

					// Wrap everything inside a swiper container
					$productGrid.wrapAll(`<div class="js-swiper-${setting} swiper-container"></div>`)

					// Wrap each product into a slide
					$productItem.removeClass("col-6 col-12 col-md-3 col-md-4 col-md-6 ").addClass("js-item-slide col-grid p-0").wrap(`<div class="swiper-slide"></div>`);
					$productItemInfoContainer.addClass("mb-0");

					// Add previous and next controls
					$productContainer.append(`
						<div class="js-products-${setting}-controls mt-2 text-center">
							<div class="js-swiper-${setting}-prev swiper-button-prev svg-icon-text">
		                        <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
		                    </div>
		                    <div class="js-swiper-${setting}-pagination swiper-pagination-fraction"></div>
		                    <div class="js-swiper-${setting}-next swiper-button-next svg-icon-text">
		                        <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
		                    </div>
						</div>
					`);

					// Initialize swiper
					createSwiper(`.js-swiper-${setting}`, {
						lazy: true,
						watchOverflow: true,
						centerInsufficientSlides: true,
						threshold: 5,
						watchSlideProgress: true,
						watchSlidesVisibility: true,
						slideVisibleClass: 'js-swiper-slide-visible',
						spaceBetween: 30,
						loop: $productItem.length > 4,
						navigation: {
							nextEl: `.js-swiper-${setting}-next`,
							prevEl: `.js-swiper-${setting}-prev`
						},
						pagination: {
							el: `.js-swiper-${setting}-pagination`,
							type: 'fraction',
						},
						slidesPerView: mobileProductQuantity,
						breakpoints: {
							768: {
								slidesPerView: desktopProductQuantity,
							}
						},
					},
					function(swiperInstance) {
						window[productSwiper] = swiperInstance;
					});
				}

				// Reset swiper function
				function resetSwiperElements() {
					const desktopProductQuantity = $productGrid.attr('data-desktop-columns');
					const mobileProductQuantity = $productGrid.attr('data-mobile-columns');

					// Remove duplicate slides and slider controls
					$productContainer.find(`.js-products-${setting}-controls`).remove();
					$productGrid.find('.swiper-slide-duplicate').remove();
					$productGrid.addClass('row row-grid');

					// Undo all slider wrappers and restore original classes
					$productGrid.unwrap();
					$productItem.unwrap();
					$productItem.removeClass('js-item-slide p-0 swiper-slide col-grid').removeAttr('style');
					$productItemInfoContainer.removeClass("mb-0");
					
					if (desktopProductQuantity == 4) {
						$productItem.addClass('col-md-3');
					} else if (desktopProductQuantity == 3) {
						$productItem.addClass('col-md-4');

					} else if (desktopProductQuantity == 2) {
						$productItem.addClass('col-md-6');
					}

					if (mobileProductQuantity == 1) {
						$productItem.addClass('col-12');

					} else if (mobileProductQuantity == 2) {
						$productItem.addClass('col-6');
					}
				}

				// Toggle grid and slider view
				handlers[`${setting}_products_format`] = new instaElements.Lambda(function(format){
					const toSlider = format == "slider";

					if ($productGrid.attr('data-format') == format) {
						// Nothing to do
						return;
					}

					// From grid to slider
					if (toSlider) {
						$productGrid.attr('data-format', 'slider');

						// Convert grid to slider if it's not yet
						if ($productContainer.find('.swiper-slide').length < 1) {
							initSwiperElements();
						}

					// From slider to grid
					} else {
						$productGrid.attr('data-format', 'grid');
						
						// Reset swiper settings
						resetSwiperElements();

						// Restore grid settings
						$productGrid.removeClass('swiper-wrapper').removeAttr('style');
					}

					// Persist new format in data attribute
					$productGrid.attr('data-format', format);
				});
			});

			// ----------------------------------- Video -----------------------------------
	
			function generateVideoThumb(videoId){
				// Generate default video thumb
				const defaultThumb = $(".js-home-video-image img");
				defaultThumb.hide();
				let defaultThumbSrc = 'https://img.youtube.com/vi_webp/' + videoId + '/maxresdefault.webp';
				defaultThumb.attr("src", defaultThumbSrc).show();
			}

			function generateVideo(videoId){
				const videoType = $('.js-home-video-container').attr("data-video-type");
				const allowCustomThumbVisibility = $('.js-home-video-container').attr("data-allow-custom-thumb");
				const customVideoThumb = $('.js-home-video-container').attr("data-custom-thumb");
				const customVideoThumbSrc = $(".js-home-video-image img").attr("src");

				// Reset existing iframe and create new one
				$(".js-home-video-iframe").remove();

				let newVideo = $('<div>', {
				    class: 'js-home-video-iframe',
				    id: 'player'
				});

				$('.js-home-video-container').append(newVideo);

				// Generate new html
				function loadVideoFrame() {
					window.youtubeIframeService.executeOnReady(() => { 
						new YT.Player('player', {
							width: '100%',
							videoId: videoId,
							playerVars: { 'autoplay': 1, 'playsinline': 1, 'rel': 0, 'loop': 1, 'autopause': 0, 'controls': 0, 'showinfo': 0, 'modestbranding': 1, 'branding': 0, 'fs': 0, 'iv_load_policy': 3 },
							events: {
								'onReady': onPlayerReady,
								'onStateChange': onPlayerStateChange
							}
						});
					});
				};
				
				if(videoType == 'autoplay'){
					loadVideoFrame();
				}else{
					$(".js-home-video-image").removeClass("d-md-none fade-in");
					if(customVideoThumb == 'true'){
						setTimeout(function(){
							$(".js-home-video-image").removeClass("d-md-none fade-in");
							$(".js-home-video-image img").attr("src" , customVideoThumbSrc).show();	
						},100);
					}else{
						generateVideoThumb(videoId);
					}
				}

				function onPlayerReady(event) {
					event.target.mute();
					event.target.playVideo();
				}

				function onPlayerStateChange(event) {
					if (event.data === YT.PlayerState.ENDED) {
						if (event.target && typeof event.target.seekTo === "function") {
							event.target.seekTo(0);
							event.target.playVideo();
						} 
					}
				}
			}

			// Update video thumbnail and iframe
			handlers.video_embed = new instaElements.Lambda(function(videoUrl){
				const $section = $('.js-section-video');
				const $container = $('.js-home-video-container');
				if (videoUrl) {
					$section.show();

					// Get video ID to create new iframe
					let videoFormat;
					let videoEmbed = videoUrl;

					if (videoEmbed.includes('/watch?v=')) {
					    videoFormat = '/watch?v=';
					} else if (videoEmbed.includes('/youtu.be/')) {
					    videoFormat = '/youtu.be/';
					} else if (videoEmbed.includes('/shorts/')) {
					    videoFormat = '/shorts/';
					}

					let videoId;
					if (videoFormat) {
					    videoId = videoEmbed.split(videoFormat).pop();
					}

					$('.js-home-video-container').attr("data-video" , videoId);
					
					// Generate new video instance
					generateVideo(videoId);

					// Show container for both video and text and signal thumbnail readiness to placeholder
					$container.attr('data-thumbnail-ready', true).show();

				} else {
					$section.hide().find(".js-home-video-iframe").attr("src" , "");
				}
			});

			// Update video type
			handlers.video_type = new instaElements.Lambda(function(videoType){
				const videoId = $('.js-home-video-container').attr('data-video');
				const $videoIframe = $('.js-home-video-iframe');
				const $playButton = $('.js-play-button');
				const $videoImage = $('.js-home-video-image');

				if (videoType == 'autoplay') {
					$playButton.hide();
					$videoImage.hide().removeClass('d-block');
					$('.js-home-video-text-container').removeClass("home-video-text-bottom").attr("data-home-video-sound", "false");
					$('.js-home-video-container').attr("data-video-type", "autoplay").attr("data-allow-custom-thumb" , "false");
				} else {
					$playButton.show();
					$videoImage.show();
					$('.js-home-video-text-container').addClass("home-video-text-bottom").attr("data-home-video-sound", "true");
					$('.js-home-video-container').attr("data-video-type", "sound").attr("data-allow-custom-thumb" , "true");
				}

				// Generate new video instance
				generateVideo(videoId);
			});

			// Toggle full-width for video
			handlers.video_full = new instaElements.Lambda(function(isFullwidth){
				const $container = $('.js-section-video-home');
				const $containerInternal = $('.js-section-video');
				if (isFullwidth) {
					$container.addClass('p-0');
					$containerInternal.removeClass("container");
				} else {
					$container.removeClass('p-0');
					$containerInternal.addClass("container");
				}
			});

			// Toggle mobile vertical for video
			handlers.video_vertical_mobile = new instaElements.Lambda(function(verticalVideo){
				const $container = $('.js-home-video-container');
				if (verticalVideo) {
					$container.addClass('embed-responsive-1by1');
				} else {
					$container.removeClass('embed-responsive-1by1');
				}
			});

			// Update visibility of text
			function videoContentVisibility(){
				const $container = $('.js-home-video-text-container');
				const hasContent = $container.find('.js-home-video-title').text().trim() || 
						$container.find('.js-home-video-text').text().trim() ||
						$container.find('.js-home-video-button').text().trim();
				let videoWithSound = $container.attr("data-home-video-sound");
				
				if(hasContent){
					$container.show();
					if(videoWithSound == 'true'){
						$container.addClass('home-video-text-bottom');
					}else{
						$container.removeClass('home-video-text-bottom');
					}
				}else{
					$container.hide();
				}
			}

			// Update title, description and button for video texts
			['title', 'text', 'button'].forEach(setting => {
				handlers[`video_${setting}`] = new instaElements.Text({
					element: `.js-home-video-${setting}`,
					show: function(){
						$(this).show();
						videoContentVisibility();
					},
					hide: function(){
						$(this).hide();
						videoContentVisibility();
					},
				});
			});

			// Updates custom thumbnail image
			handlers['video_image.jpg'] = new instaElements.Image({
				element: '.js-home-video-image img',
				show: function() {
					const allowCustomThumbVisibility = $('.js-home-video-container').attr("data-allow-custom-thumb");
					$('.js-home-video-container').attr("data-custom-thumb" , "true");
					$(".js-home-video-image").removeClass("d-md-none fade-in");
					//Show only if video is not on first position or has sound. Position info is not updated live 
					if(allowCustomThumbVisibility == 'true'){
						$(this).show();
					}
				},
				hide: function() {
					const videoId = $('.js-home-video-container').attr('data-video');
					const videoType = $('.js-home-video-container').attr("data-video-type");
					$('.js-home-video-container').attr("data-custom-thumb" , "false");

					//Hide if video has autoplay
					if(videoType == 'autoplay'){
						$(this).hide();
					}else{
						//Generate default thumb if video has sound
						generateVideoThumb(videoId);
					}
				},
			});

			// ----------------------------------- Newsletter -----------------------------------

			// Newsletter visibility

			// Updates title and text for newsletter form
			['title', 'text'].forEach(setting => {
				handlers[`home_news_${setting}`] = new instaElements.Text({
					element: `.js-home-newsletter-${setting}`,
					show: function(){
						$(this).show();
					},
					hide: function(){
						$(this).hide();
					},
				});
			});

			// Updates newsletter colors
			handlers.home_news_colors = new instaElements.Lambda(function(newsletterColors){
				const $newsletter = $('.js-newsletter-home');
				if (newsletterColors) {
					$newsletter.addClass("section-newsletter-home-colors");
				} else {
					$newsletter.removeClass("section-newsletter-home-colors");
				}
			});

			// Updates newsletter width
			handlers.home_news_full = new instaElements.Lambda(function(newsletterFullWidth){
				const $newsletterContainer = $('.js-newsletter-home-container');
				if (newsletterFullWidth) {
					$newsletterContainer.removeClass("container").addClass("container-fluid p-0");
				} else {
					$newsletterContainer.addClass("container").removeClass("container-fluid p-0");
				}
			});

			// Updates newsletter image
			handlers['home_news_image.jpg'] = new instaElements.Image({
				element: '.js-home-newsletter-image',
				show: function() {
					$(this).show();

					// Maybe show container now that there's content inside
					$(this).closest('.js-home-newsletter-image-container').show();
				},
				hide: function() {
					$(this).hide();
					
					// Maybe show container now that there's content inside
					$(this).closest('.js-home-newsletter-image-container').hide();
				},
			});

			return handlers;
		}
	};
})(jQueryNuvem);