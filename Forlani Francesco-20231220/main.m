function [] = main()
a=0;
b=1;
np=60;
Q1=[-0.2,0.2;-0.159,0.216;-0.097,0.253;-0.047,0.304;0,0.4];
%creiamo la prima parte della curva
c1=curv2_bezier_interp(Q1,a,b,2);
%creo la seconda parte della curva
Q2=Q1;
Q2(:,1)=-Q1(:,1);
c2=curv2_bezier_interp(Q2,a,b,2);
%unisco le due curve
C1=join(c1,c2);
%creiamo l'altra curva ruotando rispetto al centro quella appena trovata
C2=C1;
% punto di riferimento
riferimento = [0,0.2];
trasl = C1.cp - riferimento;
mat_rot1 = get_mat2_rot(deg2rad(180));
rot = point_trans(trasl, mat_rot1);
C2.cp = rot+riferimento;
%ora uniamo le due curve
C=ppbezier_join(C1,C2);
%disegno la curva a forma seme di quadri
open_figure(4);
curv2_ppbezier_plot(C,np,'b');
%calcoliamo e stampiamo la lunghezza della curva ottenuta
nt=length(C.ab)-1;
bez.deg=C.deg;
val=0;
for i=1:nt
    i1=(i-1)*C.deg+1;
    i2=i1+C.deg;
    bez.cp=C.cp(i1:i2,:);
    bez.ab=[C.ab(i),C.ab(i+1)];
    val =val+integral(@(x)norm_c1_val(bez,x),bez.ab(1),bez.ab(2));
end
fprintf('Lunghezza della curva a forma seme di quadri: %e\n',val); 

%ridimensioniamo i cerchi più interni che verranno disegnati
Cmedium=C;
Cmedium.cp=C.cp*1.5;

%calcoliamo il necessario per disegnare il secondo cerchio di figure 
num_cerchi2 = 5;
angle_step2 = 2 * pi / num_cerchi2;
Cplus = C;
% scaliamo la curva Cplus
Cplus.cp = 2.0 * Cplus.cp;
% calcoliamo il punto massimo di Cmedium
[max_y, idx_max] = max(Cmedium.cp(:, 2));
punto_massimo = Cmedium.cp(idx_max, :);
% trasliamo il centro di Cplus nel punto massimo di Cmedium
traslazione = punto_massimo - mean(Cplus.cp);
Cplus.cp = Cplus.cp + traslazione;

%calcoliamo il necessario per disegnare il cerchio di figure più esterno
num_cerchi3 = 12;
angle_step3 = 2 * pi / num_cerchi3;
Cminus=C;
Cminus.cp=C.cp*1.2;
% calcoliamo il punto minimo di Cminus
[min_y3, idx_min_minus] = min(Cminus.cp(:, 2));
punto_minimo_minus = Cminus.cp(idx_min_minus, :);
[~, idx_max_plus] = max(Cplus.cp(:, 2));
vertice_alto_Cplus = Cplus.cp(idx_max_plus, :);
centro_Cminus = mean(Cminus.cp);
% spostiamo il centro di Cminus al vertice alto di Cplus
Cminus.cp = Cminus.cp - centro_Cminus + [vertice_alto_Cplus(1), vertice_alto_Cplus(2)-0.1];


open_figure(3);
set(gca,'color',[0.8,1,0.8]);
%usiamo un ciclo per disegnare il cerchio di figure più esterno
for i = 1:num_cerchi3
    % calcola la trasformazione di rotazione per il prossimo cerchio
    angle = (i - 1) * angle_step3;
    mat_rot = get_mat2_rot(angle);
    % applica la rotazione alla curva Cminus
    Cminus_rotated = Cminus;
    Cminus_rotated.cp = point_trans(Cminus.cp, mat_rot);
    
    % disegna e colora la curva Cplus
    xy = curv2_ppbezier_plot(Cminus_rotated, np, 'b');
    curv2_ppbezier_plot(Cminus_rotated, np, 'b',3);
    fill(xy(:,1), xy(:,2), 'r');
end


%usiamo un ciclo per disegnare il secondo cerchio di figure
for i = 1:num_cerchi2
    % calcola la trasformazione di rotazione per il prossimo cerchio
    angle = (i - 1) * angle_step2;
    mat_rot = get_mat2_rot(angle);
     %applica la rotazione alla curva Cplus
    Cplus_rotated = Cplus;
    Cplus_rotated.cp = point_trans(Cplus.cp, mat_rot);
    
    % disegna e colora la curva Cplus
    xy = curv2_ppbezier_plot(Cplus_rotated, np, 'b');
    curv2_ppbezier_plot(Cplus_rotated, np, 'b',3);
    fill(xy(:,1), xy(:,2), 'g');
end


%usiamo un ciclo per creare il cerchio di figure più interno
num_cerchi = 4;
angle_step = 2 * pi / num_cerchi;
for i = 1:num_cerchi
    % calcola la trasformazione di rotazione per il prossimo cerchio
    angle = (i - 1) * angle_step;
    mat_rot = get_mat2_rot(angle);
    
    % applica la rotazione alla curva
    C_rotated = Cmedium;
    C_rotated.cp = point_trans(Cmedium.cp, mat_rot);
    
    %coloriamo la curva
    xy1=curv2_ppbezier_plot(C_rotated,np,'b');
    fill(xy1(:,1),xy1(:,2),'b');

end

end