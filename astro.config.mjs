// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
	site: 'https://school.majlisna.app',
	integrations: [
		starlight({
			title: 'Sousou School',
			description: 'Formation DevOps — De zéro à prêt pour l\'entretien',
			defaultLocale: 'root',
			locales: {
				root: { label: 'Français', lang: 'fr' },
				en: { label: 'English', lang: 'en' },
			},
			social: [
				{
					icon: 'github',
					label: 'GitHub',
					href: 'https://github.com/Souhib/devops-from-zero',
				},
				{
					icon: 'linkedin',
					label: 'LinkedIn',
					href: 'https://www.linkedin.com/in/souhib-trabelsi/',
				},
			],
			customCss: ['./src/styles/custom.css'],
			head: [
				{
					tag: 'meta',
					attrs: { property: 'og:image', content: 'https://school.majlisna.app/og-image.png' },
				},
				{
					tag: 'meta',
					attrs: { property: 'og:image:width', content: '1200' },
				},
				{
					tag: 'meta',
					attrs: { property: 'og:image:height', content: '630' },
				},
				{
					tag: 'meta',
					attrs: { name: 'twitter:card', content: 'summary_large_image' },
				},
				{
					tag: 'meta',
					attrs: { name: 'twitter:image', content: 'https://school.majlisna.app/og-image.png' },
				},
				{
					tag: 'link',
					attrs: {
						rel: 'preconnect',
						href: 'https://fonts.googleapis.com',
					},
				},
				{
					tag: 'link',
					attrs: {
						rel: 'preconnect',
						href: 'https://fonts.gstatic.com',
						crossorigin: true,
					},
				},
				{
					tag: 'link',
					attrs: {
						rel: 'stylesheet',
						href: 'https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap',
					},
				},
			],
			sidebar: [
				{
					label: 'Modules',
					translations: { en: 'Modules' },
					items: [
						{ slug: 'modules/00-prerequisites', label: '0. Prérequis', translations: { en: '0. Prerequisites' } },
						{ slug: 'modules/01-linux-basics', label: '1. Linux', translations: { en: '1. Linux' } },
						{ slug: 'modules/02-networking', label: '2. Réseau', translations: { en: '2. Networking' } },
						{ slug: 'modules/03-docker', label: '3. Docker', translations: { en: '3. Docker' } },
						{ slug: 'modules/04-cicd', label: '4. CI/CD', translations: { en: '4. CI/CD' } },
						{ slug: 'modules/05-aws', label: '5. AWS', translations: { en: '5. AWS' } },
						{ slug: 'modules/06-terraform', label: '6. Terraform', translations: { en: '6. Terraform' } },
						{ slug: 'modules/07-ansible', label: '7. Ansible (optionnel)', translations: { en: '7. Ansible (optional)' } },
						{ slug: 'modules/08-monitoring', label: '8. Monitoring', translations: { en: '8. Monitoring' } },
						{ slug: 'modules/09-kubernetes', label: '9. Kubernetes (optionnel)', translations: { en: '9. Kubernetes (optional)' } },
					],
				},
				{
					label: 'Entretien',
					translations: { en: 'Interview' },
					items: [
						{ slug: 'entretien/interview-questions', label: 'Questions d\'entretien', translations: { en: 'Interview Questions' } },
						{ slug: 'entretien/interview-experience', label: 'Questions d\'expérience', translations: { en: 'Experience Questions' } },
						{ slug: 'entretien/system-design', label: 'System Design', translations: { en: 'System Design' } },
					],
				},
				{
					label: 'Références',
					translations: { en: 'References' },
					items: [
						{ slug: 'references/aws-local', label: 'AWS en local', translations: { en: 'AWS Locally' } },
						{ slug: 'references/cheatsheet', label: 'Cheatsheet', translations: { en: 'Cheatsheet' } },
						{ slug: 'references/troubleshooting', label: 'Troubleshooting', translations: { en: 'Troubleshooting' } },
						{ slug: 'references/aller-plus-loin', label: 'Aller plus loin', translations: { en: 'Going Further' } },
					],
				},
				{
					label: 'Projet',
					translations: { en: 'Project' },
					items: [
						{ slug: 'projet', label: 'Projet fil rouge', translations: { en: 'Hands-on Project' } },
					],
				},
			],
			lastUpdated: true,
			pagination: true,
		}),
	],
});
