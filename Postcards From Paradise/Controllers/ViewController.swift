//
//  ViewController.swift
//  Postcards From Paradise
//
//  Created by Alejandro on 7/13/19.
//  Copyright © 2019 Alejandro. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate, UIDropInteractionDelegate, UIDragInteractionDelegate {
    
    
    
    

    @IBOutlet weak var postcardImageView: UIImageView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    var colors = [UIColor]()
    
    var image: UIImage?
    
    var topText = "App drag and Drop"
    
    var bottomText = "You can change the type font and the color font"
    
    var topFontName = "Avenir Next"
    var bottomFontName = "Avenir Next"
    
    var topFontColor = UIColor.white
    
    var bottomFontColor = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.colors += [.black, .gray, .white, .red, .orange, .yellow, .green, .cyan, .blue, .purple, .magenta]
        
        for hue in 0...9{
            for sat in 1...10{
                let color = UIColor(hue: CGFloat(hue)/10, saturation: CGFloat(sat)/10, brightness: 1, alpha: 1)
                self.colors.append(color)
            }
        }
        
        self.colorCollectionView.dragDelegate = self
        
        self.postcardImageView.isUserInteractionEnabled = true
        
        let dropInteraction = UIDropInteraction(delegate: self)
        self.postcardImageView.addInteraction(dropInteraction)
        
        let dragInteraction = UIDragInteraction(delegate: self)
        self.postcardImageView.addInteraction(dragInteraction)
        
        
        
        renderPostcard()
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
        
        let color =  self.colors[indexPath.row]
        cell.backgroundColor = color
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func renderPostcard(){
        //Definri la zona de dibujo para trabajar
        let drawRect = CGRect(x: 0, y: 0, width: 3000, height: 2400)
        
        //Crear dos rectangulos para los dos textos de la postal
        
        let topRect = CGRect(x: 300, y: 200, width: 2400, height: 800)
        let bottomRect = CGRect(x: 300, y: 1800, width: 2400, height: 600)
        
        //A partir de los nombres de lads funtes crear lso dos objetos UIFobt
        
        let topFont = UIFont(name: self.topFontName, size: 250) ?? UIFont.systemFont(ofSize: 240)
        let bottomFont = UIFont(name: self.bottomFontName, size: 120) ?? UIFont.systemFont(ofSize: 80)
        
        //dejar una fuente por defecto, por si algo falla
        
        let centered = NSMutableParagraphStyle()
        centered.alignment = .center
        
        //NSMutableParagraphStyle para centrar
        
        let topAttributes : [NSAttributedString.Key: Any] =
            [
            .foregroundColor: topFontColor,
            .font           : topFont,
            .paragraphStyle : centered
            ]
        
        let bottomAttributes: [NSAttributedString.Key : Any] =
            [
                .foregroundColor: bottomFontColor,
                .font           : bottomFont,
                .paragraphStyle : centered
            ]
        
        //Drfinir la estructura de la etiqueta como el color y al funente (NSAttributedStringKey)
        
        //Iniciar la renderizacion de la imagen (UIGraphicdImageRender
        
        let renderer = UIGraphicsImageRenderer(size: drawRect.size)
        
        self.postcardImageView.image = renderer.image(actions: { (context) in
            //renderizar la zona con un fondo gris
            
            UIColor.lightGray.set()
            context.fill(drawRect)
            
            //pintaremos la imgen seleeciona da de lususario empezando por el borde supreios izquierdo
            
            self.image?.draw(at: CGPoint(x: 0, y: 0))
            
            //Pintar las dos etiquetas de texto con los parametros configurados
            
            self.topText.draw(in: topRect, withAttributes: topAttributes)
            
            self.bottomText.draw(in: bottomRect, withAttributes: bottomAttributes)
        })
        
        
    }
    
    //MARK: - UICollectionViewDragDelegate
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let color = self.colors[indexPath.row]
        let itemProvider = NSItemProvider(object: color)
        let item = UIDragItem(itemProvider: itemProvider)
        return [item]
    }
    
    //MARK: - UIDropInteractionDelegate
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        let dropLocation = session.location(in: self.postcardImageView)
        
        if (session.hasItemsConforming(toTypeIdentifiers: [kUTTypePlainText as String])){
            // se ejecutar si lo que hemos soltado nes un String
            session.loadObjects(ofClass: NSString.self) { (items) in
                guard let fontName = items.first as? String else { return }
                if dropLocation.y < self.postcardImageView.bounds.midY{
                    self.topFontName = fontName
                }
                else{
                    self.bottomFontName = fontName
                }
                self.renderPostcard()
            }
        }
        else if(session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String])){
            // se ejecutar si lo que hemos soltado es una imagen
            session.loadObjects(ofClass: UIImage.self) { (items) in
                guard let image = items.first as? UIImage else { return }
                self.image = self.resizeImage(image: image, targetSize: CGSize(width: 3000, height: 2400))
                self.renderPostcard()
            }
            
        }
        else{
            //Se ejecutara si lo que hemos soltado es un color
            session.loadObjects(ofClass: UIColor.self) { (items) in
                guard let color = items.first as? UIColor else { return }
                
                if (dropLocation.y < self.postcardImageView.bounds.midY){
                    self.topFontColor = color
                }
                else{
                    self.bottomFontColor = color
                }
                
                self.renderPostcard()
                
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage{
        
        let originalSize = image.size
        
        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / targetSize.height
        
        let targetRadio = max(widthRatio, heightRatio)
        
        let newSize = CGSize(width: originalSize.width * targetRadio, height: originalSize.height * targetRadio)
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //MARK: - UIDragInteractionDelegate
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = self.postcardImageView.image else { return []}
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        return [item]
        
    }
    
    
    //MARK: Gesture Recognizer
    
    
    @IBAction func changeText(_ sender: UITapGestureRecognizer) {
        
        //Hay que encontrar la localizacion del tap dentro de la postal
        let tapLocation = sender.location(in: self.postcardImageView)
        
        //Decider si el usuario tiene que cambiar la etiqueta superior o inferior
        let changeTop = (tapLocation.y < self.postcardImageView.bounds.midY) ? true : false
        
        //Crear un objecto UIAlertController con un textField adicional para que el usuario escriba el texto
        
        let alert = UIAlertController(title: "Cambiar texto", message: "Escribe el nuevo texto", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "¿Que quieres poner aquí"
            if changeTop {
                textField.text = self.topText
            }
            else{
                textField.text = self.bottomText
            }
        }
        //Añadir accion "Cambiar texto" que cambie el texto pertinentemente y llame al metodo renderPostCard()
        let changeAction = UIAlertAction(title: "Cambiar Texto", style: .default) { _ in
            guard let newtext = alert.textFields?[0].text else { return }
            if changeTop{
                self.topText = newtext
            }
            else{
                self.bottomText = newtext
            }
            self.renderPostcard()
        }
        //Añadir una opcion cancelar que pare el proceso
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        //Mostrar la alert controller
        alert.addAction(changeAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
        
    }
    
    
    
}

